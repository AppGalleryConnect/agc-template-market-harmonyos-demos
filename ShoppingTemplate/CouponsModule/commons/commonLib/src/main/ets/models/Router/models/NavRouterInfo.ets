export default interface NavRouterInfo {
  url: string; // 需要跳转的路由名
  mode?: NavDestinationMode; // NavDestination类型
  param?: ESObject; // 跳转传参
  page?: ESObject;
  onPop?: Callback<PopInfo> // 返回时回调
}
