import { SourceImageModel } from '../models/PreviewModel';

export interface MovingCallback {
  onStart?: (item: SourceImageModel, index: number) => void;
  onPause?: (item: SourceImageModel, index: number) => void;
  onFinish?: (item: SourceImageModel, index: number) => void;
  onStop?: (item: SourceImageModel, index: number) => void;
  onPrepared?: (item: SourceImageModel, index: number) => void;
}

export interface ImageActionCallback {
  onScale?: (index: number, curScale: number) => void;
  onClick?: (index: number) => void;
  onLongPress?: (index: number) => void;
  onPageChanged?: (item: SourceImageModel, index: number) => void;
}

export interface PreviewCallback {
  onOpen?: () => void;
  onBack?: () => void;
}

export interface PreviewCustomBuilder {
  bottomBuilder: () => void;
  topBuilder?: () => void;
}