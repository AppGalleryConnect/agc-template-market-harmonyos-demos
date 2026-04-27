/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#ifndef AUDIO_PRORESAMPLER_PROCESS_H
#define AUDIO_PRORESAMPLER_PROCESS_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

    typedef enum MultiplyFilterFunMethod {
        MULTIPLY_FILTER_FUN_SYMMETRIC_ODD_UP,
        MULTIPLY_FILTER_FUN_SYMMETRIC_EVEN_UP,
        MULTIPLY_FILTER_FUN_UP,
        MULTIPLY_FILTER_FUN_SYMMETRIC_ODD_DOWN,
        MULTIPLY_FILTER_FUN_SYMMETRIC_EVEN_DOWN,
        MULTIPLY_FILTER_FUN_DOWN,
        MULTIPLY_FILTER_FUN_MAX
    } MultiplyFilterFunT;

    enum {
        RESAMPLER_ERR_SUCCESS = 0,
        RESAMPLER_ERR_ALLOC_FAILED = -1,
        RESAMPLER_ERR_INVALID_ARG = -2,
        RESAMPLER_ERR_OVERFLOW = -3
    };
    
    #define MAX_RATIO_INTEGRAL_METHOD 32

    typedef struct SingleStagePolyphaseResamplerState SingleStagePolyphaseResamplerState;

    typedef int32_t (*ResamplerMethod)(SingleStagePolyphaseResamplerState* state, const float* in,
        uint32_t* inputLength, float* out, uint32_t* outputLength);
    typedef void (*MultiplyFilterFun)(SingleStagePolyphaseResamplerState* state,
        const float* coeffs, const float* inputs, float* outputs, int32_t subfilterNum);


    /**
     * @brief Resampler state
     *
     */
    struct SingleStagePolyphaseResamplerState {
        uint32_t decimateFactor; /** Integer decimation factor */
        uint32_t interpolateFactor; /** Integer interpolation factor */

        int32_t quality; /** Parameter for resampler quality (0~10) */
        uint32_t numChannels; /** Number of channels */
        uint32_t filterLength; /** Number of taps of anti-aliasing/imaging filter */
        uint32_t bufferSize; /** Number of buffer samples for each channel */
        int32_t quoSamplerateRatio; /** Quotient of (input sampling frequency)/(output sampling frequency) */
        int32_t remSamplerateRatio; /** remainder of (input sampling frequency)/(output sampling frequency) */
        float cutoff; /** Normalized cutoff frequency of anti-aliasing/imaging filter */
        float coshParameter; /** Parameter of cosh window for adjusting side-lobe decay of filter */
        int32_t isInitialized; /** If the state is initialized, isInitialized=1. */
        int32_t isStarted; /** Once the resampler has processed, isStarted = 1. */

        int32_t  inputIndex; /** Index of the input to be processed. */
        uint32_t subfilterNum; /** What number of polyphase subfilters to use. */
        uint32_t magicSamples; /** Used for variable sampling frequency (don't need this?) */

        float* inputMemory; /** An array that stores the inputs to be processed. */
        uint32_t inputMemorySize; /** Size of inputMemory. (bufferSize + filterLength + 1) */
        float* filterCoefficients; /** An array that stores the polyphase filters. */
        uint32_t filterCoefficientsSize; /** Size of filterCoefficients. */
        ResamplerMethod resamplerFunction; /** A pointer to the function used for resampling. */
        MultiplyFilterFun multiplyFunSeq[MAX_RATIO_INTEGRAL_METHOD];
    };

/**
 * @brief Create a new resampler state.
 *
 * @param numChannels Number of channels.
 * @param decimateFactor Integer decimation factor (input sampling frequency).
 * @param interpolateFactor Integer interpolation factor (output sampling frequency).
 * @param quality Parameter for determining resampling quality level between 0 (poor) and 10 (best).
 * @param err
 * @return SingleStagePolyphaseResamplerState* Created resampler state used for process
 */
    SingleStagePolyphaseResamplerState* SingleStagePolyphaseResamplerInit(uint32_t numChannels,
        uint32_t decimateFactor, uint32_t interpolateFactor, int32_t quality, int32_t* err);


    /**
     * @brief Set (update) the input/output sampling rates.
     *
     * @param state Resampler state
     * @param decimateFactor Integer decimation factor (input sampling frequency).
     * @param interpolateFactor Integer interpolation factor (output sampling frequency).
     * @return int32_t returns 0 if the function terminates normally.
     */
    int32_t SingleStagePolyphaseResamplerSetRate(SingleStagePolyphaseResamplerState* state,
        uint32_t decimateFactor, uint32_t interpolateFactor);

    /**
     * @brief
     *
     * @param state Resampler state.
     * @return int32_t returns 0 if the function terminates normally.
     */
    int32_t SingleStagePolyphaseResamplerSkipHalfTaps(SingleStagePolyphaseResamplerState* state);


    /**
     * @brief Reset the buffers of the resampler.
     *
     * @param state Resampler state.
     * @return int32_t returns 0 if the function terminates normally.
     */
    int32_t SingleStagePolyphaseResamplerResetMem(SingleStagePolyphaseResamplerState* state);

    /**
     * @brief Release the memory for the resampler state
     *
     * @param state Resampler state.
     */
    void SingleStagePolyphaseResamplerFree(SingleStagePolyphaseResamplerState* state);


    /**
     * @brief Resample an input array.
     *
     * @param state resampler state
     * @param in Input array.
     * @param inputLength Number of input samples.
     * @param out Output array.
     * @param outputLength Number of input samples.
     * @return int32_t returns 0 if the function terminates normally.
     */
    int32_t SingleStagePolyphaseResamplerProcess(SingleStagePolyphaseResamplerState* state,
        const float* in, uint32_t* inputLength, float* out, uint32_t* outputLength);

#ifdef __cplusplus
}
#endif

#endif