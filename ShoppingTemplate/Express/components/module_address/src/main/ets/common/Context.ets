import { IAddrInfo } from 'module_base';
import { AddressMgrVM } from '../viewmodel/AddressMgrVM';
import { Operation } from './CommonConst';

@ObservedV2
export class Context {
  @Trace
  public navPathStack: NavPathStack = new NavPathStack();

  @Trace
  public isSelectMode: boolean = false;

  @Trace
  public onSelect: (address: IAddrInfo) => void = () => {};

  @Trace
  public operation: Operation = Operation.CREATE;

  @Trace
  public addressMgr: AddressMgrVM = new AddressMgrVM();

  @Trace
  public editingIAddrInfo: IAddrInfo | null = null;

  @Trace
  public isOnlyEdit:boolean = false
}
