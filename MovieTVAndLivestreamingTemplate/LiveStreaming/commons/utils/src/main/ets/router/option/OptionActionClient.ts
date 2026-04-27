
import { BaseRouterOption } from '../RouterConfig';

export interface OptionActionClient {
  execute(options: BaseRouterOption): Promise<boolean>;
}