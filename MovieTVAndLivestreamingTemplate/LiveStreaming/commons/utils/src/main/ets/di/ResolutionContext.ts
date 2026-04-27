import { Registration } from "./Registry";

export default class ResolutionContext {
  scopedResolutions: Map<Registration, any> = new Map();
}
