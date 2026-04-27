export function getNamesFromPath(path: string) : string {
  const res = path.split('/')
  return res[res.length - 1]
}