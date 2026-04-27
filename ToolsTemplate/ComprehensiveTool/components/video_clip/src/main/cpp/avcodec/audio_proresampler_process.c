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

#include <stdlib.h>
#include <math.h>
#include <limits.h>
#include <stdint.h>
#include "audio_proresampler_process.h"
#include "avcodec_log.h"
#include <string.h>

/**
 * @brief Ratio of circumference to diameter
 *
 */
#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

/**
 * @brief Maximum number of numChannels
 *
 */
#define MAX_NUM_CHANNEL 16


#ifndef NULL
#define NULL 0
#endif

#ifndef MONO
#define MONO 1
#endif

#ifndef STEREO
#define STEREO 2
#endif

#define TWO_STEPS 2
#define THREE_STEPS 3
#define FOUR_STEPS 4
#define QUALITY_LEVEL_TEN 10
#define BUFFER_SIZE 160

// WARNING: Code for support to sudden changes in sampling frequency is deprecated!
// It is disabled because it is complex and untested.
// It is desirable to re-initialize for such a change in the sampling frequency.

/**
 * @brief A function that compares two values and returns the smaller one
 *
 */

static inline uint32_t CompareMin(uint32_t a, uint32_t b)
{
    return a < b ? a : b;
}

/**
 * @brief A function that compares two values and returns the larger one
 *
 */
static inline uint32_t CompareMax(uint32_t a, uint32_t b)
{
    return a < b ? b : a;
}

/**
 * @brief A function that helps update resampler state
 *
*/
static int32_t UpdateFilterMemory(SingleStagePolyphaseResamplerState* state, uint32_t oldFilterLength);
struct QualityTable {
    int32_t filterLength;
    float coshParameter;
};


/**
 * @brief This table contains internal parameters corresponding to quality levels.
 *
 * The relationship between coshParameter and side lobe decay is as follows:
 * coshParameter = -8.722e-5 * attenuation^TWO_STEPS + 0.1335 * attenuation - 1.929 (50 < attenuation)
 */
static const struct QualityTable QUALITY_TABLE[11] = {
    {  8, 5.767008}, /* Q0 */
    { 16, 5.767008}, /* Q1 */
    { 32, 5.767008}, /* Q2 */ /*  ( ~60 dB stop) 6  */
    { 48, 8.192792}, /* Q3 */ /*  ( ~80 dB stop) 8  */
    { 64, 8.192792}, /* Q4 */ /*  ( ~80 dB stop) 8  */
    { 80, 10.5488},  /* Q5 */ /*  (~100 dB stop) 10 */
    { 96, 10.5488},  /* Q6 */ /*  (~100 dB stop) 10 */
    {128, 10.5488},  /* Q7 */ /*  (~100 dB stop) 10 */
    {160, 10.5488},  /* Q8 */ /*  (~100 dB stop) 10 */
    {192, 10.5488},  /* Q9 */ /*  (~100 dB stop) 10 */
    {256, 10.5488}, /* Q10 */ /*  (~100 dB stop) 10 */
};


static double CompHyperbolicCosineWindow(double x, float alpha)
{
    double x2;
    double w;

    x2 = x * x;
    if (x2 >= 1.0) {
        return 0.f;
    }

    w = alpha * sqrt(1.0f - x2);
    w = cosh(w) / cosh(alpha);
    return w;
}


static float Sinc(float x)
{
    if (fabs(x) < 1e-6) {
        return 1.0f;
    }
    return sin(M_PI * x) / (M_PI * x);
}


static int32_t CalculateFilter(SingleStagePolyphaseResamplerState* state)
{
    uint32_t i;
    uint32_t j;
    float phi0 = 0;
    float phi = 0;
    double w;
    uint32_t requiredFilterCoefficientsSize;
    float cutoff = state->cutoff;

    if (INT_MAX / sizeof(float) / state->interpolateFactor < state->filterLength) {
        return RESAMPLER_ERR_ALLOC_FAILED;
    }

    requiredFilterCoefficientsSize = state->filterLength * state->interpolateFactor;

    if (state->filterCoefficientsSize < requiredFilterCoefficientsSize) {
        if (state->filterCoefficients == NULL) {
            state->filterCoefficients = (float*)malloc(requiredFilterCoefficientsSize * sizeof(float));
            CHECK_AND_RETURN_RET_LOG(state->filterCoefficients, RESAMPLER_ERR_ALLOC_FAILED,
                "malloc state->filterCoefficients fail!");
        } else {
            float* filterCoefficients = (float*)malloc(requiredFilterCoefficientsSize * sizeof(float));
            CHECK_AND_RETURN_RET_LOG(filterCoefficients, RESAMPLER_ERR_ALLOC_FAILED, "malloc filterCoefficients fail!");
            memcpy(filterCoefficients, state->filterCoefficients, state->filterCoefficientsSize * sizeof(float));
            free(state->filterCoefficients);
            state->filterCoefficients = filterCoefficients;
        }
        state->filterCoefficientsSize = requiredFilterCoefficientsSize;
    }

    for (i = 0; i < state->interpolateFactor; i++) {
        for (j = 0; j < state->filterLength; j++) {
            phi = ((int32_t)j - (int32_t)state->filterLength / TWO_STEPS + 1) - phi0;
            w = CompHyperbolicCosineWindow(fabs((double)TWO_STEPS * phi / state->filterLength),
                state->coshParameter);
            state->filterCoefficients[i * state->filterLength + j] = w * cutoff * Sinc(cutoff * phi);
        }
        phi0 += 1.0 / state->interpolateFactor;
    }
    return 0;
}

/*====== Filter multiplication function for general cases =====*/
static void MultiplyFilterMono(SingleStagePolyphaseResamplerState* state, const float* coeffs,
    const float* inputs, float* outputs, int32_t subfilterNum)
{
    float sum = 0;

    for (uint32_t j = 0; j < state->filterLength; j += FOUR_STEPS) {
        sum += (*coeffs++) * (*inputs++);
        sum += (*coeffs++) * (*inputs++);
        sum += (*coeffs++) * (*inputs++);
        sum += (*coeffs++) * (*inputs++);
    }
    *outputs = sum;
}

static void MultiplyFilterStereo(SingleStagePolyphaseResamplerState* state, const float* coeffs,
    const float* inputs, float* outputs, int32_t subfilterNum)
{
    float sumL = 0;
    float sumR = 0;
    float h;

    for (uint32_t j = 0; j < state->filterLength; j += FOUR_STEPS) {
        h = *coeffs++;
        sumL += h * (*inputs++);
        sumR += h * (*inputs++);

        h = *coeffs++;
        sumL += h * (*inputs++);
        sumR += h * (*inputs++);

        h = *coeffs++;
        sumL += h * (*inputs++);
        sumR += h * (*inputs++);

        h = *coeffs++;
        sumL += h * (*inputs++);
        sumR += h * (*inputs++);
    }
    *outputs++ = sumL;
    *outputs = sumR;
}

static void MultiplyFilterMultichannel(SingleStagePolyphaseResamplerState* state, const float* coeffs,
    const float* inputs, float* outputs, int32_t subfilterNum)
{
    const uint32_t numChannels = state->numChannels;
    uint32_t ch;
    uint32_t j;
    float h;
    float sum[MAX_NUM_CHANNEL];

    for (ch = 0; ch < numChannels; ch++) {
        sum[ch] = 0;
    }
    for (j = 0; j < state->filterLength; j += FOUR_STEPS) {
        h = *coeffs++;
        for (ch = 0; ch < numChannels; ch++) {
            sum[ch] += h * (*inputs++);
        }
        h = *coeffs++;
        for (ch = 0; ch < numChannels; ch++) {
            sum[ch] += h * (*inputs++);
        }
        h = *coeffs++;
        for (ch = 0; ch < numChannels; ch++) {
            sum[ch] += h * (*inputs++);
        }
        h = *coeffs++;
        for (ch = 0; ch < numChannels; ch++) {
            sum[ch] += h * (*inputs++);
        }
    }
    for (ch = 0; ch < numChannels; ch++) {
        *outputs++ = sum[ch];
    }
}

/*===== Filter multiplication function for coarse (integral) upsampling =====*/
static void MultiplyFilterSymmetricOddUpMono(SingleStagePolyphaseResamplerState* state, const float* coeffs,
    const float* inputs, float* outputs, int32_t subfilterNum)
{
    *outputs = inputs[state->filterLength / TWO_STEPS - 1];
}

static void MultiplyFilterSymmetricOddUpStereo(SingleStagePolyphaseResamplerState* state, const float* coeffs,
    const float* inputs, float* outputs, int32_t subfilterNum)
{
    *outputs++ = inputs[state->filterLength - TWO_STEPS];
    *outputs = inputs[state->filterLength - 1];
}

static void MultiplyFilterSymmetricOddUpMultichannel(SingleStagePolyphaseResamplerState* state, const float* coeffs,
    const float* inputs, float* outputs, int32_t subfilterNum)
{
    const int32_t indCenter = state->filterLength / TWO_STEPS - 1;
    for (uint32_t ch = 0; ch < state->numChannels; ch++) {
        *outputs++ = inputs[state->numChannels * indCenter + ch];
    }
}

static void MultiplyFilterSymmetricEvenUpMono(SingleStagePolyphaseResamplerState* state, const float* coeffs,
    const float* inputs, float* outputs, int32_t subfilterNum)
{
    const int32_t n = state->filterLength;
    float sum = 0;

    for (int32_t j = 0; j < n / TWO_STEPS; j += FOUR_STEPS) {
        sum += (*coeffs++) * (inputs[j] + inputs[(n - j - 1)]);
        sum += (*coeffs++) * (inputs[j + 1] + inputs[(n - (j + 1) - 1)]);
        sum += (*coeffs++) * (inputs[j + TWO_STEPS] + inputs[(n - (j + TWO_STEPS) - 1)]);
        sum += (*coeffs++) * (inputs[j + THREE_STEPS] + inputs[(n - (j + THREE_STEPS) - 1)]);
    }
    *outputs = sum;
}

static void MultiplyFilterSymmetricEvenUpStereo(SingleStagePolyphaseResamplerState* state, const float* coeffs,
    const float* inputs, float* outputs, int32_t subfilterNum)
{
    const int32_t n = state->filterLength;
    float sumL = 0;
    float sumR = 0;
    float h;

    for (int32_t j = 0; j < n / TWO_STEPS; j += FOUR_STEPS) {
        h = *coeffs++;
        sumL += h * (inputs[j * STEREO] + inputs[(n - j - 1) * STEREO]);
        sumR += h * (inputs[j * STEREO + 1] + inputs[(n - j - 1) * STEREO + 1]);
        h = *coeffs++;
        sumL += h * (inputs[(j + 1) * STEREO] + inputs[(n - (j + 1) - 1) * STEREO]);
        sumR += h * (inputs[(j + 1) * STEREO + 1] + inputs[(n - (j + 1) - 1) * STEREO + 1]);
        h = *coeffs++;
        sumL += h * (inputs[(j + TWO_STEPS) * STEREO] + inputs[(n - (j + TWO_STEPS) - 1) * STEREO]);
        sumR += h * (inputs[(j + TWO_STEPS) * STEREO + 1] + inputs[(n - (j + TWO_STEPS) - 1) * STEREO + 1]);
        h = *coeffs++;
        sumL += h * (inputs[(j + THREE_STEPS) * STEREO] + inputs[(n - (j + THREE_STEPS) - 1) * STEREO]);
        sumR += h * (inputs[(j + THREE_STEPS) * STEREO + 1] + inputs[(n - (j + THREE_STEPS) - 1) * STEREO + 1]);
    }
    *outputs++ = sumL;
    *outputs++ = sumR;
}

static void MultiplyFilterSymmetricEvenUpMultichannel(SingleStagePolyphaseResamplerState* state, const float* coeffs,
    const float* inputs, float* outputs, int32_t subfilterNum)
{
    const int32_t n = state->filterLength;
    const int32_t numChannels = state->numChannels;
    int32_t ch;
    int32_t j;
    float sum[MAX_NUM_CHANNEL];
    float h;

    for (ch = 0; ch < numChannels; ch++) {
        sum[ch] = 0;
    }
    for (j = 0; j < n / TWO_STEPS; j++) {
        h = *coeffs++;
        for (ch = 0; ch < numChannels; ch++) {
            sum[ch] += h * (inputs[j * numChannels + ch] + inputs[(n - j - 1) * numChannels + ch]);
        }
    }
    for (ch = 0; ch < numChannels; ch++) {
        *outputs++ = sum[ch];
    }
}

static void MultiplyFilterSymmetricOddDownMono(SingleStagePolyphaseResamplerState* state, const float* coeffs,
    const float* inputs, float* outputs, int32_t subfilterNum)
{
    const uint32_t n = state->filterLength;
    const uint32_t indCenter = n / TWO_STEPS - 1;
    const uint32_t decimateFactor = state->decimateFactor;
    float sum;
    uint32_t rem = indCenter % decimateFactor;
    uint32_t len = indCenter / decimateFactor;
    uint32_t i;
    uint32_t j;
    uint32_t l;
    // center index
    sum = coeffs[indCenter] * inputs[indCenter];
    // symmetric indices
    for (j = 0; j < rem; j++) {
        sum += (*coeffs++) * (inputs[j] + inputs[(n - j - TWO_STEPS)]);
    }
    for (l = 0; l < len; l++) {
        coeffs++;
        j++;
        for (i = 1; i < decimateFactor; i++) {
            sum += (*coeffs++) * (inputs[j] + inputs[(n - j - TWO_STEPS)]);
            j++;
        }
    }

    *outputs = sum;
}

static void MultiplyFilterSymmetricOddDownStereo(SingleStagePolyphaseResamplerState* state, const float* coeffs,
    const float* inputs, float* outputs, int32_t subfilterNum)
{
    const uint32_t n = state->filterLength;
    const uint32_t indCenter = n / TWO_STEPS - 1;
    const uint32_t decimateFactor = state->decimateFactor;
    float sumL;
    float sumR;
    float h;
    uint32_t rem = indCenter % decimateFactor;
    uint32_t len = indCenter / decimateFactor;
    uint32_t i;
    uint32_t j;
    uint32_t l;

    // center
    h = coeffs[indCenter];
    sumL = h * inputs[n - TWO_STEPS];
    sumR = h * inputs[n - 1];
    // symmetric indices
    for (j = 0; j < rem; j++) {
        h = *coeffs++;
        sumL += h * (inputs[j * STEREO] + inputs[(n - j - TWO_STEPS) * STEREO]);
        sumR += h * (inputs[j * STEREO + 1] + inputs[(n - j - TWO_STEPS) * STEREO + 1]);
    }
    for (l = 0; l < len; l++) {
        coeffs++;
        j++;
        for (i = 1; i < decimateFactor; i++) {
            h = *coeffs++;
            sumL += h * (inputs[j * STEREO] + inputs[(n - j - TWO_STEPS) * STEREO]);
            sumR += h * (inputs[j * STEREO + 1] + inputs[(n - j - TWO_STEPS) * STEREO + 1]);
            j++;
        }
    }

    *outputs++ = sumL;
    *outputs = sumR;
}

static void MultiplyFilterSymmetricOddDownMultichannel(SingleStagePolyphaseResamplerState* state, const float* coeffs,
    const float* inputs, float* outputs, int32_t subfilterNum)
{
    const uint32_t n = state->filterLength;
    const uint32_t numChannels = state->numChannels;
    const uint32_t indCenter = n / TWO_STEPS - 1;
    const uint32_t decimateFactor = state->decimateFactor;
    uint32_t i;
    uint32_t j;
    uint32_t l;
    uint32_t ch;
    float sum[MAX_NUM_CHANNEL];
    float h;
    uint32_t rem = indCenter % decimateFactor;
    uint32_t len = indCenter / decimateFactor;

    // center index
    h = coeffs[indCenter];
    for (ch = 0; ch < numChannels; ch++) {
        sum[ch] = h * (inputs[indCenter * numChannels + ch]);
    }
    // symmetric indices
    for (j = 0; j < rem; j++) {
        h = *coeffs++;
        for (ch = 0; ch < numChannels; ch++) {
            sum[ch] += h * (inputs[j * numChannels + ch] + inputs[(n - j - TWO_STEPS) * numChannels + ch]);
        }
    }
    for (l = 0; l < len; l++) {
        coeffs++;
        j++;
        for (i = 1; i < decimateFactor; i++) {
            h = *coeffs++;
            for (ch = 0; ch < numChannels; ch++) {
                sum[ch] += h * (inputs[j * numChannels + ch] + inputs[(n - j - TWO_STEPS) * numChannels + ch]);
            }
            j++;
        }
    }

    for (ch = 0; ch < numChannels; ch++) {
        *outputs++ = sum[ch];
    }
}


static void MultiplyFilterSymmetricEvenDownMono(SingleStagePolyphaseResamplerState* state, const float* coeffs,
    const float* inputs, float* outputs, int32_t subfilterNum)
{
    const uint32_t n = state->filterLength;
    const uint32_t decimateFactor = state->decimateFactor;
    uint32_t i;
    uint32_t j;
    uint32_t l;
    uint32_t rem = (n / TWO_STEPS) % decimateFactor;
    uint32_t len = (n / TWO_STEPS) / decimateFactor;
    float h;

    float sum = 0;

    // symmetric indices
    for (j = 0; j < rem; j++) {
        h = *coeffs++;
        sum += h * (inputs[j] + inputs[(n - j - 1)]);
    }
    for (l = 0; l < len; l++) {
        for (i = 0; i < decimateFactor / TWO_STEPS; i++) {
            h = *coeffs++;
            sum += h * (inputs[j] + inputs[(n - j - 1)]);
            j++;
        }
        // Skip zero
        coeffs++;
        j++;
        for (i = 0; i < decimateFactor / TWO_STEPS; i++) {
            h = *coeffs++;
            sum += h * (inputs[j] + inputs[(n - j - 1)]);
            j++;
        }
    }
    *outputs = sum;
}

static void MultiplyFilterSymmetricEvenDownStereo(SingleStagePolyphaseResamplerState* state, const float* coeffs,
    const float* inputs, float* outputs, int32_t subfilterNum)
{
    const uint32_t n = state->filterLength;
    const uint32_t decimateFactor = state->decimateFactor;
    uint32_t i;
    uint32_t j;
    uint32_t l;
    uint32_t rem = (n / TWO_STEPS) % decimateFactor;
    uint32_t len = (n / TWO_STEPS) / decimateFactor;
    float h;

    float sumL = 0;
    float sumR = 0;

    // symmetric indices
    for (j = 0; j < rem; j++) {
        h = *coeffs++;
        sumL += h * (inputs[j * STEREO] + inputs[(n - j - 1) * STEREO]);
        sumR += h * (inputs[j * STEREO + 1] + inputs[(n - j - 1) * STEREO + 1]);
    }
    for (l = 0; l < len; l++) {
        for (i = 0; i < decimateFactor / TWO_STEPS; i++) {
            h = *coeffs++;
            sumL += h * (inputs[j * STEREO] + inputs[(n - j - 1) * STEREO]);
            sumR += h * (inputs[j * STEREO + 1] + inputs[(n - j - 1) * STEREO + 1]);
            j++;
        }
        // Skip zero
        coeffs++;
        j++;
        for (i = 0; i < decimateFactor / TWO_STEPS; i++) {
            h = *coeffs++;
            sumL += h * (inputs[j * STEREO] + inputs[(n - j - 1) * STEREO]);
            sumR += h * (inputs[j * STEREO + 1] + inputs[(n - j - 1) * STEREO + 1]);
            j++;
        }
    }
    *outputs++ = sumL;
    *outputs++ = sumR;
}


static void MultiplyFilterSymmetricEvenDownMultichannel(SingleStagePolyphaseResamplerState* state, const float* coeffs,
    const float* inputs, float* outputs, int32_t subfilterNum)
{
    const uint32_t n = state->filterLength;
    const uint32_t numChannels = state->numChannels;
    const uint32_t decimateFactor = state->decimateFactor;
    uint32_t i;
    uint32_t j;
    uint32_t l;
    uint32_t ch;
    float sum[MAX_NUM_CHANNEL];
    float h;
    uint32_t rem = (n / TWO_STEPS) % decimateFactor;
    uint32_t len = (n / TWO_STEPS) / decimateFactor;

    for (ch = 0; ch < numChannels; ch++) {
        sum[ch] = 0;
    }
    // symmetric indices
    for (j = 0; j < rem; j++) {
        h = *coeffs++;
        for (ch = 0; ch < numChannels; ch++) {
            sum[ch] += h * (inputs[j * numChannels + ch] + inputs[(n - j - 1) * numChannels + ch]);
        }
    }
    for (l = 0; l < len; l++) {
        for (i = 0; i < decimateFactor / TWO_STEPS; i++) {
            h = *coeffs++;
            for (ch = 0; ch < numChannels; ch++) {
                sum[ch] += h * (inputs[j * numChannels + ch] + inputs[(n - j - 1) * numChannels + ch]);
            }
            j++;
        }
        // Skip zero
        coeffs++;
        j++;
        for (i = 0; i < decimateFactor / TWO_STEPS; i++) {
            h = *coeffs++;
            for (ch = 0; ch < numChannels; ch++) {
                sum[ch] += h * (inputs[j * numChannels + ch] + inputs[(n - j - 1) * numChannels + ch]);
            }
            j++;
        }
    }

    for (ch = 0; ch < numChannels; ch++) {
        *outputs++ = sum[ch];
    }
}

static void MultiplyFilterDownMono(SingleStagePolyphaseResamplerState *state, const float *coeffs,
    const float *inputs, float *outputs, int32_t subfilterNum)
{
    const int32_t n = state->filterLength;
    const int32_t indCenter = n / TWO_STEPS - 1;
    const uint32_t decimateFactor = state->decimateFactor;
    int32_t j;
    float h;
    float sum = 0;

    int32_t counts = indCenter % decimateFactor - subfilterNum;
    if (counts < 0) {
        counts += state->interpolateFactor;
    }

    for (j = 0; j < n; j++) {
        h = *coeffs++;
        if (counts == 0) { // Skip zero coefficients
            counts = decimateFactor - 1;
            inputs++;
            continue;
        }
        sum += h * (*inputs++);
        counts--;
    }
    *outputs = sum;
}

static void MultiplyFilterDownStereo(SingleStagePolyphaseResamplerState* state, const float* coeffs,
    const float* inputs, float* outputs, int32_t subfilterNum)
{
    const int32_t n = state->filterLength;
    const int32_t indCenter = n / TWO_STEPS - 1;
    const uint32_t decimateFactor = state->decimateFactor;
    int32_t j;
    float sumL = 0;
    float sumR = 0;
    float h;

    int32_t counts = indCenter % decimateFactor - subfilterNum;
    if (counts < 0) {
        counts += state->interpolateFactor;
    }

    for (j = 0; j < n; j++) {
        h = *coeffs++;
        if (counts == 0) { // Skip zero coefficients
            counts = decimateFactor - 1;
            inputs += STEREO;
            continue;
        }
        sumL += h * (*inputs++);
        sumR += h * (*inputs++);
        counts--;
    }
    *outputs++ = sumL;
    *outputs = sumR;
}

static void MultiplyFilterDownMultichannel(SingleStagePolyphaseResamplerState *state, const float *coeffs,
    const float *inputs, float *outputs, int32_t subfilterNum)
{
    const int32_t n = state->filterLength;
    const int32_t indCenter = n / TWO_STEPS - 1;
    const uint32_t decimateFactor = state->decimateFactor;
    const int32_t numChannels = state->numChannels;
    int32_t j;
    int32_t ch;
    float h;
    float sum[MAX_NUM_CHANNEL];

    int32_t counts = indCenter % decimateFactor - subfilterNum;
    if (counts < 0) {
        counts += state->interpolateFactor;
    }

    for (ch = 0; ch < numChannels; ch++) {
        sum[ch] = 0;
    }
    for (j = 0; j < n; j++) {
        h = *coeffs++;
        if (counts == 0) { // Skip zero coefficients
            counts = decimateFactor - 1;
            inputs += numChannels;
            continue;
        }
        for (ch = 0; ch < numChannels; ch++) {
            sum[ch] += h * (*inputs++);
        }
        counts--;
    }
    for (ch = 0; ch < numChannels; ch++) {
        *outputs++ = sum[ch];
    }
}


/*===== Function pointers of filter multiplication functions =====*/
static MultiplyFilterFun multiplyFilterFunTable[] = {
    [THREE_STEPS * MULTIPLY_FILTER_FUN_SYMMETRIC_ODD_UP]          = MultiplyFilterSymmetricOddUpMono,
    [THREE_STEPS * MULTIPLY_FILTER_FUN_SYMMETRIC_ODD_UP + 1]      = MultiplyFilterSymmetricOddUpStereo,
    [THREE_STEPS * MULTIPLY_FILTER_FUN_SYMMETRIC_ODD_UP + TWO_STEPS] = MultiplyFilterSymmetricOddUpMultichannel,
    [THREE_STEPS * MULTIPLY_FILTER_FUN_SYMMETRIC_EVEN_UP]         = MultiplyFilterSymmetricEvenUpMono,
    [THREE_STEPS * MULTIPLY_FILTER_FUN_SYMMETRIC_EVEN_UP + 1]     = MultiplyFilterSymmetricEvenUpStereo,
    [THREE_STEPS * MULTIPLY_FILTER_FUN_SYMMETRIC_EVEN_UP + TWO_STEPS] = MultiplyFilterSymmetricEvenUpMultichannel,
    [THREE_STEPS * MULTIPLY_FILTER_FUN_UP]                        = MultiplyFilterMono,
    [THREE_STEPS * MULTIPLY_FILTER_FUN_UP + 1]                    = MultiplyFilterStereo,
    [THREE_STEPS * MULTIPLY_FILTER_FUN_UP + TWO_STEPS]            = MultiplyFilterMultichannel,
    [THREE_STEPS * MULTIPLY_FILTER_FUN_SYMMETRIC_ODD_DOWN]        = MultiplyFilterSymmetricOddDownMono,
    [THREE_STEPS * MULTIPLY_FILTER_FUN_SYMMETRIC_ODD_DOWN + 1]    = MultiplyFilterSymmetricOddDownStereo,
    [THREE_STEPS * MULTIPLY_FILTER_FUN_SYMMETRIC_ODD_DOWN + TWO_STEPS] =
        MultiplyFilterSymmetricOddDownMultichannel,
    [THREE_STEPS * MULTIPLY_FILTER_FUN_SYMMETRIC_EVEN_DOWN]       = MultiplyFilterSymmetricEvenDownMono,
    [THREE_STEPS * MULTIPLY_FILTER_FUN_SYMMETRIC_EVEN_DOWN + 1]   = MultiplyFilterSymmetricEvenDownStereo,
    [THREE_STEPS * MULTIPLY_FILTER_FUN_SYMMETRIC_EVEN_DOWN + TWO_STEPS] =
        MultiplyFilterSymmetricEvenDownMultichannel,
    [THREE_STEPS * MULTIPLY_FILTER_FUN_DOWN]                      = MultiplyFilterDownMono,
    [THREE_STEPS * MULTIPLY_FILTER_FUN_DOWN + 1]                  = MultiplyFilterDownStereo,
    [THREE_STEPS * MULTIPLY_FILTER_FUN_DOWN + TWO_STEPS]          = MultiplyFilterDownMultichannel
};

static int32_t PolyphaseResamplerMono(SingleStagePolyphaseResamplerState *state, const float *in, uint32_t *inputLength,
    float *out, uint32_t *outputLength)
{
    const int32_t n = state->filterLength;
    int32_t outSample = 0;
    int32_t inputIndex = state->inputIndex;
    uint32_t subfilterNum = state->subfilterNum;
    const float* filterCoefficients = state->filterCoefficients;
    const int32_t quoSamplerateRatio = state->quoSamplerateRatio;
    const int32_t remSamplerateRatio = state->remSamplerateRatio;
    const uint32_t decimateFactor = state->decimateFactor;
    const uint32_t interpolateFactor = state->interpolateFactor;
    int32_t i;

    if (inputIndex < (int32_t)(*inputLength)) {
        outSample = CompareMin((*outputLength), ((interpolateFactor * ((*inputLength) - inputIndex) -
            subfilterNum) - 1) / decimateFactor + 1);
    }

    for (i = 0; i < outSample; i++) {
        const float* coeffs = &filterCoefficients[subfilterNum * n];
        const float* inputs = &in[inputIndex * MONO];
        MultiplyFilterMono(state, coeffs, inputs, out, subfilterNum);
        out++;

        inputIndex += quoSamplerateRatio;
        subfilterNum += remSamplerateRatio;
        if (subfilterNum >= interpolateFactor) {
            subfilterNum -= interpolateFactor;
            inputIndex++;
        }
    }

    state->inputIndex = inputIndex;
    state->subfilterNum = subfilterNum;
    return outSample;
}

static int32_t PolyphaseResamplerStereo(SingleStagePolyphaseResamplerState* state, const float* in,
    uint32_t* inputLength, float* out, uint32_t* outputLength)
{
    const int32_t n = state->filterLength;
    int32_t outSample = 0;
    int32_t inputIndex = state->inputIndex;
    uint32_t subfilterNum = state->subfilterNum;
    const float* filterCoefficients = state->filterCoefficients;
    const int32_t quoSamplerateRatio = state->quoSamplerateRatio;
    const int32_t remSamplerateRatio = state->remSamplerateRatio;
    const uint32_t decimateFactor = state->decimateFactor;
    const uint32_t interpolateFactor = state->interpolateFactor;
    int32_t i;

    if (inputIndex < (int32_t) (*inputLength)) {
        outSample = CompareMin((*outputLength), ((interpolateFactor * ((*inputLength) - inputIndex) -
            subfilterNum) - 1) / decimateFactor + 1);
    }
    for (i = 0; i < outSample; i++) {
        const float* coeffs = &filterCoefficients[subfilterNum * n];
        const float* inputs = &in[inputIndex * STEREO];
        MultiplyFilterStereo(state, coeffs, inputs, out, subfilterNum);
        out += STEREO;

        inputIndex += quoSamplerateRatio;
        subfilterNum += remSamplerateRatio;
        if (subfilterNum >= interpolateFactor) {
            subfilterNum -= interpolateFactor;
            inputIndex++;
        }
    }

    state->inputIndex = inputIndex;
    state->subfilterNum = subfilterNum;
    return outSample;
}

static int32_t PolyphaseResamplerMultichannel(SingleStagePolyphaseResamplerState* state, const float* in,
    uint32_t* inputLength, float* out, uint32_t* outputLength)
{
    const int32_t n = state->filterLength;
    int32_t outSample = 0;
    int32_t inputIndex = state->inputIndex;
    uint32_t subfilterNum = state->subfilterNum;
    const float* filterCoefficients = state->filterCoefficients;
    const int32_t quoSamplerateRatio = state->quoSamplerateRatio;
    const int32_t remSamplerateRatio = state->remSamplerateRatio;
    const uint32_t decimateFactor = state->decimateFactor;
    const uint32_t interpolateFactor = state->interpolateFactor;
    const int32_t numChannels = state->numChannels;
    int32_t i;

    if (inputIndex < (int32_t)(*inputLength)) {
        outSample = CompareMin((*outputLength), ((interpolateFactor *
            ((*inputLength) - inputIndex) - subfilterNum) - 1) / decimateFactor + 1);
    }

    for (i = 0; i < outSample; i++) {
        const float* coeffs = &filterCoefficients[subfilterNum * n];
        const float* inputs = &in[inputIndex * numChannels];
        MultiplyFilterMultichannel(state, coeffs, inputs, out, subfilterNum);
        out += numChannels;

        inputIndex += quoSamplerateRatio;
        subfilterNum += remSamplerateRatio;
        if (subfilterNum >= interpolateFactor) {
            subfilterNum -= interpolateFactor;
            inputIndex++;
        }
    }

    state->inputIndex = inputIndex;
    state->subfilterNum = subfilterNum;
    return outSample;
}

static int32_t PolyphaseDownsamplerHalfbandMono(SingleStagePolyphaseResamplerState* state, const float* in,
    uint32_t* inputLength, float* out, uint32_t* outputLength)
{
    const int32_t n = state->filterLength;
    const int32_t indCenter = n / TWO_STEPS - 1;
    int32_t outSample = 0;
    int32_t inputIndex = state->inputIndex;
    const float* filterCoefficients = state->filterCoefficients;
    float hCenter = filterCoefficients[indCenter];
    int32_t i;
    int32_t j;
    float sum;

    if (inputIndex < (int32_t)(*inputLength)) {
        outSample = CompareMin((*outputLength), (((*inputLength) - inputIndex) - 1) / TWO_STEPS + 1);
    }

    for (i = 0; i < outSample; i++) {
        const float *coeffs = &filterCoefficients[0];

        const float *inputs = &in[inputIndex];
        // center
        sum = hCenter * inputs[indCenter];
        // symmetric indices
        for (j = 0; j < indCenter; j += TWO_STEPS) {
            sum += (*coeffs) * (inputs[j] + inputs[(n - j - TWO_STEPS)]);
            coeffs += TWO_STEPS;
        }
        *out++ = sum;
        inputIndex += TWO_STEPS;
    }

    state->inputIndex = inputIndex;
    return outSample;
}

static int32_t PolyphaseDownsamplerHalfbandStereo(SingleStagePolyphaseResamplerState* state, const float* in,
    uint32_t* inputLength, float* out, uint32_t* outputLength)
{
    const int32_t n = state->filterLength;
    const int32_t indCenter = n / TWO_STEPS - 1;
    int32_t outSample = 0;
    int32_t inputIndex = state->inputIndex;
    const float* filterCoefficients = state->filterCoefficients;
    float hCenter = filterCoefficients[indCenter];
    int32_t i;
    int32_t j;
    float sumL;
    float sumR;
    float h;

    if (inputIndex < (int32_t)(*inputLength)) {
        outSample = CompareMin((*outputLength), (((*inputLength) - inputIndex) - 1) / TWO_STEPS + 1);
    }

    for (i = 0; i < outSample; i++) {
        const float* coeffs = &filterCoefficients[0];
        const float* inputs = &in[inputIndex * STEREO];

        // center
        sumL = hCenter * inputs[n - TWO_STEPS];
        sumR = hCenter * inputs[n - 1];
        // symmetric indices
        for (j = 0; j < indCenter; j += TWO_STEPS) {
            h = *coeffs;
            sumL += h * (inputs[j * STEREO] + inputs[(n - j - TWO_STEPS) * STEREO]);
            sumR += h * (inputs[j * STEREO + 1] + inputs[(n - j - TWO_STEPS) * STEREO + 1]);
            coeffs += TWO_STEPS;
        }
        *out++ = sumL;
        *out++ = sumR;
        inputIndex += TWO_STEPS;
    }

    state->inputIndex = inputIndex;
    return outSample;
}

static int32_t PolyphaseDownsamplerHalfbandMultichannel(SingleStagePolyphaseResamplerState* state, const float* in,
    uint32_t* inputLength, float* out, uint32_t* outputLength)
{
    const int32_t n = state->filterLength;
    const int32_t indCenter = n / TWO_STEPS - 1;
    int32_t outSample = 0;
    int32_t inputIndex = state->inputIndex;
    const float* filterCoefficients = state->filterCoefficients;
    float hCenter = filterCoefficients[indCenter];
    int32_t i;
    int32_t j;
    int32_t ch;
    float h;
    float sum[MAX_NUM_CHANNEL];
    const int32_t numChannels = state->numChannels;

    if (inputIndex < (int32_t)(*inputLength)) {
        outSample = CompareMin((*outputLength), (((*inputLength) - inputIndex) - 1) / TWO_STEPS + 1);
    }

    for (i = 0; i < outSample; i++) {
        const float* coeffs = &filterCoefficients[0];
        const float* inputs = &in[inputIndex * numChannels];

        // center
        for (ch = 0; ch < numChannels; ch++) {
            sum[ch] = hCenter * inputs[indCenter * numChannels + ch];
        }
        // symmetric indices
        for (j = 0; j < indCenter; j += TWO_STEPS) {
            h = *coeffs;
            for (ch = 0; ch < numChannels; ch++) {
                sum[ch] += h * (inputs[j * numChannels + ch] + inputs[(n - j - TWO_STEPS) * numChannels + ch]);
            }
            coeffs += TWO_STEPS;
        }
        for (ch = 0; ch < numChannels; ch++) {
            *out++ = sum[ch];
        }
        inputIndex += TWO_STEPS;
    }

    state->inputIndex = inputIndex;
    return outSample;
}

static int32_t PolyphaseDownsamplerThirdbandMono(SingleStagePolyphaseResamplerState* state, const float* in,
    uint32_t* inputLength, float* out, uint32_t* outputLength)
{
    const int32_t n = state->filterLength;
    const int32_t indCenter = n / TWO_STEPS - 1;
    int32_t outSample = 0;
    int32_t inputIndex = state->inputIndex;
    const float* filterCoefficients = state->filterCoefficients;
    int32_t i;
    int32_t j;
    float sum;
    int32_t rem = indCenter % THREE_STEPS;
    float hCenter = filterCoefficients[indCenter];

    if (inputIndex < (int32_t)(*inputLength)) {
        outSample = CompareMin((*outputLength), (((*inputLength) - inputIndex) - 1) / THREE_STEPS + 1);
    }

    for (i = 0; i < outSample; i++) {
        const float* coeffs = &filterCoefficients[0];
        const float* inputs = &in[inputIndex];

        // center
        sum = hCenter * inputs[indCenter];
        // symmetric indices
        for (j = 0; j < rem; j++) {
            sum += (*coeffs++) * (inputs[j] + inputs[(n - j - TWO_STEPS)]);
        }
        coeffs++;
        for (j = rem + 1; j < indCenter; j += THREE_STEPS) {
            sum += (*coeffs++) * (inputs[j] + inputs[(n - j - TWO_STEPS)]);
            sum += (*coeffs++) * (inputs[(j + 1)] + inputs[(n - (j + 1) - TWO_STEPS)]);
            coeffs++;
        }
        *out++ = sum;
        inputIndex += THREE_STEPS;
    }

    state->inputIndex = inputIndex;
    return outSample;
}

static int32_t PolyphaseDownsamplerThirdbandStereo(SingleStagePolyphaseResamplerState* state, const float* in,
    uint32_t* inputLength, float* out, uint32_t* outputLength)
{
    const int32_t n = state->filterLength;
    const int32_t indCenter = n / TWO_STEPS - 1;
    int32_t outSample = 0;
    int32_t inputIndex = state->inputIndex;
    const float* filterCoefficients = state->filterCoefficients;
    int32_t i;
    int32_t j;
    float sumL;
    float sumR;
    float h;

    int32_t rem = indCenter % THREE_STEPS;
    float hCenter = filterCoefficients[indCenter];

    if (inputIndex < (int32_t)(*inputLength)) {
        outSample = CompareMin((*outputLength), (((*inputLength) - inputIndex) - 1) / THREE_STEPS + 1);
    }

    for (i = 0; i < outSample; i++) {
        const float* coeffs = &filterCoefficients[0];
        const float* inputs = &in[inputIndex * STEREO];

        // center
        sumL = hCenter * inputs[n - TWO_STEPS];
        sumR = hCenter * inputs[n - 1];

        // symmetric indices
        for (j = 0; j < rem; j++) {
            h = *coeffs++;
            sumL += h * (inputs[j * STEREO] + inputs[(n - j - TWO_STEPS) * STEREO]);
            sumR += h * (inputs[j * STEREO + 1] + inputs[(n - j - TWO_STEPS) * STEREO + 1]);
        }
        coeffs++;
        for (j = rem + 1; j < indCenter; j += THREE_STEPS) {
            h = *coeffs++;
            sumL += h * (inputs[j * STEREO] + inputs[(n - j - TWO_STEPS) * STEREO]);
            sumR += h * (inputs[j * STEREO + 1] + inputs[(n - j - TWO_STEPS) * STEREO + 1]);
            h = *coeffs++;
            sumL += h * (inputs[(j + 1) * STEREO] + inputs[(n - (j + 1) - TWO_STEPS) * STEREO]);
            sumR += h * (inputs[(j + 1) * STEREO + 1] + inputs[(n - (j + 1) - TWO_STEPS) * STEREO + 1]);
            coeffs++;
        }
        *out++ = sumL;
        *out++ = sumR;
        inputIndex += THREE_STEPS;
    }

    state->inputIndex = inputIndex;
    return outSample;
}

static int32_t PolyphaseDownsamplerThirdbandMultichannel(SingleStagePolyphaseResamplerState* state, const float* in,
    uint32_t* inputLength, float* out, uint32_t* outputLength)
{
    const int32_t n = state->filterLength;
    const int32_t indCenter = n / TWO_STEPS - 1;
    int32_t outSample = 0;
    int32_t inputIndex = state->inputIndex;
    const float* filterCoefficients = state->filterCoefficients;
    int32_t i;
    int32_t j;
    int32_t ch;
    float h1;
    float h2;
    float sum[MAX_NUM_CHANNEL];
    const int32_t numChannels = state->numChannels;
    int32_t rem = indCenter % THREE_STEPS;
    float hCenter = filterCoefficients[indCenter];

    if (inputIndex < (int32_t)(*inputLength)) {
        outSample = CompareMin((*outputLength), (((*inputLength) - inputIndex) - 1) / THREE_STEPS + 1);
    }

    for (i = 0; i < outSample; i++) {
        const float* coeffs = &filterCoefficients[0];
        const float* inputs = &in[inputIndex * numChannels];

        // center
        for (ch = 0; ch < numChannels; ch++) {
            sum[ch] = hCenter * (inputs[indCenter * numChannels + ch]);
        }

        // symmetric indices
        for (j = 0; j < rem; j++) {
            h1 = *coeffs++;
            for (ch = 0; ch < numChannels; ch++) {
                sum[ch] += h1 * (inputs[j * numChannels + ch] + inputs[(n - j - TWO_STEPS) * numChannels + ch]);
            }
        }
        coeffs++;
        for (j = rem + 1; j < indCenter; j += THREE_STEPS) {
            h1 = *coeffs++;
            h2 = *coeffs++;
            for (ch = 0; ch < numChannels; ch++) {
                sum[ch] += h1 * (inputs[j * numChannels + ch] + inputs[(n - j - TWO_STEPS) * numChannels + ch]);
                sum[ch] += h2 * (inputs[(j + 1) * numChannels + ch] + inputs[(n - (j + 1) - TWO_STEPS) *
                    numChannels + ch]);
            }
            coeffs++;
        }
        for (ch = 0; ch < numChannels; ch++) {
            *out++ = sum[ch];
        }
        inputIndex += THREE_STEPS;
    }

    state->inputIndex = inputIndex;
    return outSample;
}

static int32_t PolyphaseResamplerCoarse(SingleStagePolyphaseResamplerState* state, const float* in,
    uint32_t* inputLength, float* out, uint32_t* outputLength)
{
    const int32_t n = state->filterLength;
    int32_t outSample = 0;
    int32_t inputIndex = state->inputIndex;
    uint32_t subfilterNum = state->subfilterNum;
    const float* filterCoefficients = state->filterCoefficients;
    const int32_t quoSamplerateRatio = state->quoSamplerateRatio;
    const int32_t remSamplerateRatio = state->remSamplerateRatio;
    const uint32_t decimateFactor = state->decimateFactor;
    const uint32_t interpolateFactor = state->interpolateFactor;
    const int32_t numChannels = state->numChannels;
    int32_t i;

    if (inputIndex < (int32_t)(*inputLength)) {
        outSample = CompareMin((*outputLength), ((interpolateFactor * ((*inputLength) - inputIndex) -
            subfilterNum) - 1) / decimateFactor + 1);
    }

    for (i = 0; i < outSample; i++) {
        const float* coeffs = &filterCoefficients[subfilterNum * n];
        const float* inputs = &in[inputIndex * numChannels];

        state->multiplyFunSeq[subfilterNum](state, coeffs, inputs, out, subfilterNum);
        out += numChannels;

        inputIndex += quoSamplerateRatio;
        subfilterNum += remSamplerateRatio;
        if (subfilterNum >= interpolateFactor) {
            subfilterNum -= interpolateFactor;
            inputIndex++;
        }
    }

    state->inputIndex = inputIndex;
    state->subfilterNum = subfilterNum;
    return outSample;
}

/*
 * This resampler is used to produce zero output in situations where memory for the filter could not be allocated.
 */
static int32_t PolyphaseResamplerZero(SingleStagePolyphaseResamplerState* state, const float* in,
    uint32_t* inputLength, float* out, uint32_t* outputLength)
{
    int32_t outSample = 0;
    int32_t inputIndex = state->inputIndex;
    uint32_t subfilterNum = state->subfilterNum;
    const int32_t quoSamplerateRatio = state->quoSamplerateRatio;
    const int32_t remSamplerateRatio = state->remSamplerateRatio;
    const uint32_t decimateFactor = state->decimateFactor;
    const uint32_t interpolateFactor = state->interpolateFactor;
    const int32_t numChannels = state->numChannels;
    int32_t i;
    int32_t ch;

    (void)in;

    if (inputIndex < (int32_t)(*inputLength)) {
        outSample = CompareMin((*outputLength), ((interpolateFactor * ((*inputLength) - inputIndex) -
            subfilterNum) - 1) / decimateFactor + 1);
    }

    for (i = 0; i < outSample; i++) {
        for (ch = 0; ch < numChannels; ch++) {
            *out++ = 0;
        }

        inputIndex += quoSamplerateRatio;
        subfilterNum += remSamplerateRatio;
        if (subfilterNum >= interpolateFactor) {
            subfilterNum -= interpolateFactor;
            inputIndex++;
        }
    }

    state->inputIndex = inputIndex;
    state->subfilterNum = subfilterNum;
    return outSample;
}

static MultiplyFilterFun GetMultiplyFilterFun(SingleStagePolyphaseResamplerState* state, uint32_t i)
{
    int32_t channelMode = CompareMin(state->numChannels - 1, STEREO);

    if (state->interpolateFactor < state->decimateFactor) { // downsampling
        if (i == 0) {
            return multiplyFilterFunTable[THREE_STEPS * MULTIPLY_FILTER_FUN_SYMMETRIC_ODD_DOWN + channelMode];
        }
        if ((uint32_t)TWO_STEPS * i == state->interpolateFactor) {
            return multiplyFilterFunTable[THREE_STEPS * MULTIPLY_FILTER_FUN_SYMMETRIC_EVEN_DOWN + channelMode];
        }
        return multiplyFilterFunTable[THREE_STEPS * MULTIPLY_FILTER_FUN_DOWN + channelMode];
    } else { // upsampling
        if (i == 0) {
            return multiplyFilterFunTable[THREE_STEPS * MULTIPLY_FILTER_FUN_SYMMETRIC_ODD_UP + channelMode];
        }
        if ((uint32_t)TWO_STEPS * i == state->interpolateFactor) {
            return multiplyFilterFunTable[THREE_STEPS * MULTIPLY_FILTER_FUN_SYMMETRIC_EVEN_UP + channelMode];
        }
        return multiplyFilterFunTable[THREE_STEPS * MULTIPLY_FILTER_FUN_UP + channelMode];
    }
}

static ResamplerMethod SetResamplerFunctionCoarse(SingleStagePolyphaseResamplerState* state)
{
    if (TWO_STEPS * state->interpolateFactor == state->decimateFactor) {
        // Specific function for downsample by 2
        switch (state->numChannels) {
        case MONO:
            return PolyphaseDownsamplerHalfbandMono;
        case STEREO:
            return PolyphaseDownsamplerHalfbandStereo;
        default:
            return PolyphaseDownsamplerHalfbandMultichannel;
        }
    }
    if (THREE_STEPS * state->interpolateFactor == state->decimateFactor) {
        // Specific function for downsample by 3
        switch (state->numChannels) {
        case MONO:
            return PolyphaseDownsamplerThirdbandMono;
        case STEREO:
            return PolyphaseDownsamplerThirdbandStereo;
        default:
            return PolyphaseDownsamplerThirdbandMultichannel;
        }
    }

    for (uint32_t j = 0; j < state->interpolateFactor; j++) {
        state->multiplyFunSeq[j] = GetMultiplyFilterFun(state, j);
    }
    return PolyphaseResamplerCoarse;
}

static int32_t UpdateResamplerState(SingleStagePolyphaseResamplerState* state)
{
    uint32_t oldFilterLength = state->filterLength;

    state->quoSamplerateRatio = state->decimateFactor / state->interpolateFactor;
    state->remSamplerateRatio = state->decimateFactor % state->interpolateFactor;
    state->filterLength = QUALITY_TABLE[state->quality].filterLength;
    state->coshParameter = QUALITY_TABLE[state->quality].coshParameter;

    if (state->interpolateFactor < state->decimateFactor) { // downsampling
        state->cutoff = (float)state->interpolateFactor / state->decimateFactor;
        state->filterLength = state->filterLength * state->decimateFactor / state->interpolateFactor;

        // Round up to make sure filterLength be multiple of 8
        state->filterLength = 8 * ((state->filterLength - 1) / 8) + 8;
    } else { // upsampling
        state->cutoff = 1;
    }
    
    // modified for new requirements (extended i/o sample rate combination) 2025.2.28
    if ((CompareMax(state->decimateFactor, state->interpolateFactor) <= MAX_RATIO_INTEGRAL_METHOD) &
        ((state->decimateFactor == 1 || state->interpolateFactor == 1) ||
            ((float)state->decimateFactor / (float)state->interpolateFactor < 2.0f))) {
        state->resamplerFunction = SetResamplerFunctionCoarse(state);
    } else { // fine (non-integral) sampling rate ratio
        switch (state->numChannels) {
        case MONO:
            state->resamplerFunction = PolyphaseResamplerMono;
            break;
        case STEREO:
            state->resamplerFunction = PolyphaseResamplerStereo;
            break;
        default:
            state->resamplerFunction = PolyphaseResamplerMultichannel;
        }
    }

    CalculateFilter(state);

    /* Here's the place where we update the filter memory to take into account
       the change in filter length. It's probably the messiest part of the code
       due to handling of lots of corner cases. */
    return UpdateFilterMemory(state, oldFilterLength);
}

static int32_t UpdateFilterMemory(SingleStagePolyphaseResamplerState* state, uint32_t oldFilterLength)
{
    /* Adding bufferSize to filterLength won't overflow here because filterLength
        could be multiplied by sizeof(float) above. */
    uint32_t requiredInputMemorySize = state->filterLength - 1 + state->bufferSize;
    if (requiredInputMemorySize > state->inputMemorySize) {
        if (state->inputMemory == NULL) { // first time initiaization
            state->inputMemory = (float*)malloc(state->numChannels * requiredInputMemorySize * sizeof(float));
            CHECK_AND_RETURN_RET_LOG(state->inputMemory, RESAMPLER_ERR_ALLOC_FAILED,
                "first time requiredInputMemorySize %{public}d alloc failed", requiredInputMemorySize);
        } else {
            float* inputMemory = (float*)malloc(state->numChannels * requiredInputMemorySize * sizeof(float));
            CHECK_AND_RETURN_RET_LOG(inputMemory, RESAMPLER_ERR_ALLOC_FAILED,
                "requiredInputMemorySize %{public}d alloc failed", requiredInputMemorySize);
            memcpy(inputMemory, state->inputMemory, state->inputMemorySize * state->numChannels * sizeof(float));
            if (INT_MAX / sizeof(float) / state->numChannels < requiredInputMemorySize) {
                state->resamplerFunction = PolyphaseResamplerZero;
                /* state->mem may still contain consumed input samples for the filter.
                Restore filterLength so that filterLength - 1 still points to the position after
                the last of these samples. */
                state->filterLength = oldFilterLength;
                return RESAMPLER_ERR_ALLOC_FAILED;
            }
            free(state->inputMemory);
            state->inputMemory = inputMemory;
        }
        state->inputMemorySize = requiredInputMemorySize;
    }
    /* codes for sudden sample rate change are deprecated and deleted so far */
    uint32_t i;
    for (i = 0; i < state->numChannels * state->inputMemorySize; i++) {
        state->inputMemory[i] = 0;
    }
    return RESAMPLER_ERR_SUCCESS;
}

static int32_t SingleStagePolyphaseResamplerSetQuality(SingleStagePolyphaseResamplerState* state, int32_t quality)
{
    if (quality > QUALITY_LEVEL_TEN || quality < 0) {
        return RESAMPLER_ERR_INVALID_ARG;
    }
    if (state->quality == quality) {
        return RESAMPLER_ERR_SUCCESS;
    }
    state->quality = quality;
    if (state->isInitialized) {
        return UpdateResamplerState(state);
    }
    return RESAMPLER_ERR_SUCCESS;
}

SingleStagePolyphaseResamplerState* SingleStagePolyphaseResamplerInit(uint32_t numChannels,
    uint32_t decimateFactor, uint32_t interpolateFactor, int32_t quality, int32_t* err)
{
    SingleStagePolyphaseResamplerState* state;
    int32_t filterErr;

    if (numChannels == 0 || decimateFactor == 0 || interpolateFactor == 0 || quality > QUALITY_LEVEL_TEN ||
        quality < 0) {
        if (err) {
            *err = RESAMPLER_ERR_INVALID_ARG;
        }
        return NULL;
    }
    state = (SingleStagePolyphaseResamplerState*)calloc(sizeof(SingleStagePolyphaseResamplerState), 1);
    if (!state) {
        if (err) {
            *err = RESAMPLER_ERR_ALLOC_FAILED;
        }
        return NULL;
    }
    state->isInitialized = 0;
    state->isStarted = 0;
    state->decimateFactor = 0;
    state->interpolateFactor = 0;
    state->quality = -1;
    state->filterCoefficientsSize = 0;
    state->inputMemorySize = 0;
    state->filterLength = 0;
    state->filterCoefficients = NULL;
    state->inputMemory = NULL;
    state->resamplerFunction = 0;

    state->cutoff = 1.f;
    state->numChannels = numChannels;

    state->bufferSize = BUFFER_SIZE;

    state->inputIndex = 0;
    state->magicSamples = 0;
    state->subfilterNum = 0;

    SingleStagePolyphaseResamplerSetQuality(state, quality);
    filterErr = SingleStagePolyphaseResamplerSetRate(state, decimateFactor, interpolateFactor);
    filterErr = UpdateResamplerState(state);
    if (filterErr == RESAMPLER_ERR_SUCCESS) {
        state->isInitialized = 1;
    } else {
        SingleStagePolyphaseResamplerFree(state);
        state = NULL;
    }
    if (err) {
        *err = filterErr;
    }
    return state;
}

static void ApplyResampler(SingleStagePolyphaseResamplerState* state, uint32_t* inputLength,
    float* out, uint32_t* outputLength)
{
    const int32_t n = state->filterLength;
    int32_t outSample = 0;
    float* inputMemory = state->inputMemory;
    uint32_t inputSize;
    const int32_t numChannels = state->numChannels;
    int32_t j;

    state->isStarted = 1;
    /* Call resampler function */
    outSample = state->resamplerFunction(state, inputMemory, inputLength, out, outputLength);

    if (state->inputIndex < (int32_t)*inputLength) {
        *inputLength = state->inputIndex;
    }
    *outputLength = outSample;
    state->inputIndex -= *inputLength;

    inputSize = (*inputLength) * numChannels;
    for (j = 0; j < (n - 1) * numChannels; j++) {
        inputMemory[j] = inputMemory[j + inputSize];
    }
}


static inline uint32_t ComputeGcd(uint32_t a, uint32_t b)
{
    while (b != 0) {
        uint32_t temp = a;

        a = b;
        b = temp % b;
    }
    return a;
}


int32_t SingleStagePolyphaseResamplerProcess(SingleStagePolyphaseResamplerState* state, const float* in,
    uint32_t* inputLength, float* out, uint32_t* outputLength)
{
    uint32_t j;
    uint32_t remainingInputLength = *inputLength;
    uint32_t remainingOutputLength = *outputLength;
    const int32_t filtOffs = state->filterLength - 1;
    const uint32_t bufferLen = state->inputMemorySize - filtOffs;
    const int32_t numChannels = state->numChannels;
    float* buf = state->inputMemory + filtOffs * numChannels;

    while (remainingInputLength && remainingOutputLength) {
        uint32_t processInputLength = (remainingInputLength > bufferLen) ? bufferLen : remainingInputLength;
        uint32_t processOutputLength = remainingOutputLength;

        if (in) {
            for (j = 0; j < processInputLength * numChannels; j++) {
                buf[j] = in[j];
            }
        } else {
            for (j = 0; j < processInputLength * numChannels; j++) {
                buf[j] = 0;
            }
        }
        ApplyResampler(state, &processInputLength, out, &processOutputLength);
        remainingInputLength -= processInputLength;
        remainingOutputLength -= processOutputLength;
        out += processOutputLength * numChannels;
        if (in) {
            in += processInputLength * numChannels;
        }
    }

    *inputLength -= remainingInputLength;
    *outputLength -= remainingOutputLength;
    return state->resamplerFunction == PolyphaseResamplerZero ? RESAMPLER_ERR_ALLOC_FAILED : RESAMPLER_ERR_SUCCESS;
}

int32_t SingleStagePolyphaseResamplerSetRate(SingleStagePolyphaseResamplerState* state, uint32_t decimateFactor,
    uint32_t interpolateFactor)
{
    uint32_t fact;
    uint32_t oldInterpolateFactor;

    if (decimateFactor == 0 || interpolateFactor == 0) {
        return RESAMPLER_ERR_INVALID_ARG;
    }

    if (state->decimateFactor == decimateFactor && state->interpolateFactor == interpolateFactor) {
        return RESAMPLER_ERR_SUCCESS;
    }

    oldInterpolateFactor = state->interpolateFactor;
    state->decimateFactor = decimateFactor;
    state->interpolateFactor = interpolateFactor;

    fact = ComputeGcd(state->decimateFactor, state->interpolateFactor);
    CHECK_AND_RETURN_RET_LOG(fact != 0, RESAMPLER_ERR_OVERFLOW, "fact is zero, invalid");
    state->decimateFactor /= fact;
    state->interpolateFactor /= fact;

    if (oldInterpolateFactor > 0) {
        state->subfilterNum = state->subfilterNum * state->interpolateFactor / oldInterpolateFactor;

        /* Safety net */
        if (state->subfilterNum >= state->interpolateFactor) {
            state->subfilterNum = state->interpolateFactor - 1;
        }
    }

    if (state->isInitialized) {
        return UpdateResamplerState(state);
    }
    return RESAMPLER_ERR_SUCCESS;
}

int32_t SingleStagePolyphaseResamplerSkipHalfTaps(SingleStagePolyphaseResamplerState* state)
{
    state->inputIndex = state->filterLength / TWO_STEPS;
    return RESAMPLER_ERR_SUCCESS;
}


void SingleStagePolyphaseResamplerFree(SingleStagePolyphaseResamplerState* state)
{
    free(state->inputMemory);
    state->inputMemory = NULL;
    free(state->filterCoefficients);
    state->filterCoefficients = NULL;
    free(state);
    state = NULL;
}


int32_t SingleStagePolyphaseResamplerResetMem(SingleStagePolyphaseResamplerState* state)
{
    uint32_t i;
    state->inputIndex = 0;
    state->magicSamples = 0;
    state->subfilterNum = 0;

    for (i = 0; i < state->numChannels * state->inputMemorySize; i++) {
        state->inputMemory[i] = 0;
    }
    return RESAMPLER_ERR_SUCCESS;
}