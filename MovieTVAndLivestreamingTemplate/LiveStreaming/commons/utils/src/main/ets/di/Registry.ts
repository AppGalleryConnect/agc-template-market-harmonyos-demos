import { Provider } from "./providers";
import { RegistrationOptions } from "./types";
import RegistryBase from "./RegistryBase";

export type Registration<T = any> = {
  provider: Provider<T>;
  options: RegistrationOptions;
  instance?: T;
};

export default class Registry extends RegistryBase<Registration> {}
