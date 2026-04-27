export enum FileType {
  FILE = 1,
  FOLDER = 2,
  ZIP = 3,
}

export enum CompressedFormat {
  ZIP = 'zip',
  ZZ = '7z',
}

export const compressedFormat: string[] = ['zip', '7z']

export enum WorkerMessageType {
  COMPRESS = 'compress',
  DECOMPRESS = 'decompress',
  SAVE = 'save'
}