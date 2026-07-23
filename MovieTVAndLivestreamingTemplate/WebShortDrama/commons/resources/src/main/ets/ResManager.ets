export function getString(resKey: string, ...params: Array<number | string>): Resource {
  return $r(resKey, ...params);
}

export function getMedia(resKey: string, ...params: Array<number | string>): Resource {
  return $r(resKey, ...params);
}

export function getColor(resKey: string): Resource {
  return $r(resKey);
}

export function getStringSync(resource: Resource): string {
  let ctx: UIContext = AppStorage.get('UIContext')!
  return ctx.getHostContext()!.resourceManager.getStringSync(resource.id)
}