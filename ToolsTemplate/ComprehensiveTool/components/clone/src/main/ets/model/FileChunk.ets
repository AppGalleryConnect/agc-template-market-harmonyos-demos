export interface FileChunk {
  fileSize: number;
  totalChunks: number;
  chunkSize: number;
  currentPosition: number;
}