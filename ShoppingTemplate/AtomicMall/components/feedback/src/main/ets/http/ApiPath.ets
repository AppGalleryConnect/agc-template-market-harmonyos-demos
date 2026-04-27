/**
 * API 路径常量
 */
export enum ApiPath {
  /**
   * 上传图片
   * POST multipart/form-data
   */
  UPLOAD_IMAGE = '/api/v1/uploads',
  /**
   * 提交反馈
   * POST application/json
   */
  SUBMIT_FEEDBACK = '/api/v1/feedbacks',
  /**
   * 查询反馈记录列表
   * GET application/json
   */
  LIST_FEEDBACKS = '/api/v1/feedbacks',
}
