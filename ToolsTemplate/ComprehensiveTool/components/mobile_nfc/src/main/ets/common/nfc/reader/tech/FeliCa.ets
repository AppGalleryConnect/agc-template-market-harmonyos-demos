import { tag } from '@kit.ConnectivityKit';
import Util from '../../../Util';
import NFC from '../../Nfc';

export default class FeliCa {
  static EMPTY: number[] = [];
  data: number[]

  constructor(data?: number[]) {
    this.data = data ? data : FeliCa.EMPTY;
  }

  size(): number {
    return this.data.length;
  }

  getBytes(): number[] {
    return this.data;
  }
}

export class IDm extends FeliCa {
  static EMPTY = [0, 0, 0, 0, 0, 0, 0, 0,];

  constructor(bytes?: number[]) {
    super((!bytes || bytes.length < 8) ? IDm.EMPTY : bytes);
  }

  getManufactureCode(): string {
    return Util.toHexString2(this.data, 0, 2);
  }

  getCardIdentification(): string {
    return Util.toHexString2(this.data, 2, 6);
  }

  isEmpty(): boolean {
    for (let v of this.data) {
      if (v !== 0) {
        return false;
      }
    }
    return true;
  }
}

export class PMm extends FeliCa {
  static EMPTY = [0, 0, 0, 0, 0, 0, 0, 0,];

  constructor(bytes?: number[]) {
    super((!bytes || bytes.length < 8) ? PMm.EMPTY : bytes);
  }

  getIcCode(): string {
    return Util.toHexString2(this.data, 0, 2);
  }

  getMaximumResponseTime(): string {
    return Util.toHexString2(this.data, 2, 6);
  }
}

export class SystemCode extends FeliCa {
  static EMPTY = [0, 0,]

  constructor(bytes?: number[]) {
    super((!bytes || bytes.length < 2) ? SystemCode.EMPTY : bytes);
  }

  toInt(data?: number[]): number {
    if (!data) {
      data = this.data
    }
    return 0x0000FFFF & ((data[0] << 8) | (0x000000FF & data[1]));
  }
}

export class ServiceCode extends FeliCa {
  static EMPTY = [0, 0,]
  static T_UNKNOWN = 0;
  static T_RANDOM = 1;
  static T_CYCLIC = 2;
  static T_PURSE = 3;

  constructor(code?: number, bytes?: number[]) {
    if (code) {
      bytes = [(code & 0xFF), (code >> 8)]
    }
    super((!bytes || bytes.length < 2) ? ServiceCode.EMPTY : bytes);
  }

  toInt(): number {
    return 0x0000FFFF & ((this.data[1] << 8) | (0x000000FF & this.data[0]));
  }

  isEncrypt(): boolean {
    return (this.data[0] & 0x1) === 0;
  }

  isWritable(): boolean {
    let f = this.data[0] & 0x3F;
    return (f & 0x2) === 0 || f === 0x13 || f === 0x12;
  }

  getAccessAttr(): number {
    return this.data[0] & 0x3F;
  }

  getDataType(): number {
    let f = this.data[0] & 0x3F;
    if ((f & 0x10) === 0) {
      return ServiceCode.T_PURSE;
    }

    return ((f & 0x04) === 0) ? ServiceCode.T_RANDOM : ServiceCode.T_CYCLIC;
  }
}

export class Command extends FeliCa {
  length: number
  code: number
  idm?: IDm

  constructor(data: number[] | undefined, length: number, code: number, idm?: IDm) {
    super(data);
    this.length = length;
    this.code = code;
    this.idm = idm;
  }

  static create1(bytes: number[]): Command {
    return Command.create2(bytes[0], bytes.slice(1));
  }

  static create2(code: number, bytes: number[]): Command {
    let idm: IDm | undefined
    if (bytes.length >= 8) {
      idm = new IDm(bytes.slice(0, 8));
      bytes = bytes.slice(8)
    } else {
      idm = undefined;
      bytes = bytes;
    }
    return new Command(bytes, bytes.length + 2, code, idm)
  }

  static create3(code: number, idm: IDm, bytes: number[]): Command {
    return new Command(bytes, idm.getBytes().length + bytes.length + 2, code, idm)
  }

  static create4(code: number, idm: number[], bytes: number[]): Command {
    return new Command(bytes, idm.length + bytes.length + 2, code, new IDm(idm))
  }

  getBytes(): number[] {
    let buff: number[] = []
    if (this.idm) {
      buff.push(this.length)
      buff.push(this.code)
      for (let b of this.idm.getBytes()) {
        buff.push(b)
      }
      for (let b of this.data) {
        buff.push(b)
      }
    } else {
      buff.push(this.length)
      buff.push(this.code)
      for (let b of this.data) {
        buff.push(b)
      }
    }
    return buff;
  }
}

export class Response extends FeliCa {
  length: number
  code: number
  idm: IDm

  constructor(bytes: number[] | undefined) {
    if (bytes && bytes.length >= 10) {
      super(bytes)
      this.length = bytes[0] & 0xff;
      this.code = bytes[1];
      this.idm = new IDm(bytes.slice(2, 10));
    } else {
      super(FeliCa.EMPTY);
      this.length = 0;
      this.code = 0;
      this.idm = new IDm(undefined);
    }
  }

  public getIDm(): IDm {
    return this.idm;
  }
}

export class PollingResponse extends Response {
  pmm: PMm;

  constructor(bytes: number[] | undefined) {
    super(bytes);
    if (this.size() >= 18) {
      this.pmm = new PMm(this.data.slice(10, 18));
    } else {
      this.pmm = new PMm(undefined);
    }
  }

  public getPMm(): PMm {
    return this.pmm;
  }
}

export class ReadResponse extends Response {
  static EMPTY = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0xFF, 0xFF];
  blockData: number[];

  constructor(rsp: number[]) {
    super((rsp === null || rsp?.length < 12) ? ReadResponse.EMPTY : rsp);
    if (this.getStatusFlag1() === STA1_NORMAL && this.getBlockCount() > 0) {
      this.blockData = this.data.slice(13);
    } else {
      this.blockData = FeliCa.EMPTY;
    }
  }

  public getStatusFlag1(): number {
    return this.data[10] & 0x000000FF;
  }

  public getStatusFlag2(): number {
    return this.data[11] & 0x000000FF;
  }

  public getStatusFlag12(): number {
    return (this.getStatusFlag1() << 8) | this.getStatusFlag2();
  }

  public getBlockCount(): number {
    return (this.data.length > 12) ? (0xFF & this.data[12]) : 0;
  }

  public getBlockData(): number[] {
    return this.blockData;
  }

  public isOkey(): boolean {
    return this.getStatusFlag1() === STA1_NORMAL;
  }
}

export class WriteResponse extends Response {
  constructor(rsp: number[]) {
    super((rsp === null || rsp.length < 12) ? ReadResponse.EMPTY : rsp);
  }

  public getStatusFlag1(): number {
    return this.data[0] & 0x000000FF;
  }

  public getStatusFlag2(): number {
    return this.data[1] & 0x000000FF;
  }

  public getStatusFlag12(): number {
    return (this.getStatusFlag1() << 8) | this.getStatusFlag2();
  }

  public isOkey(): boolean {
    return this.getStatusFlag1() === STA1_NORMAL;
  }
}

export class Tag {
  nfcTag: tag.NfcFTag;
  isFeliCaLite: boolean = false
  sys: number[];
  idm: IDm
  pmm: PMm

  constructor(nfcTag: tag.NfcFTag) {
    this.nfcTag = nfcTag
    this.sys = nfcTag.getSystemCode();
    this.idm = new IDm(tag.getTagInfo(NFC.startWant).uid);
    this.pmm = new PMm(nfcTag.getPmm());
  }

  getIDm(): IDm {
    return this.idm;
  }

  getPMm(): PMm {
    return this.pmm;
  }

  async polling(systemCode: number): Promise<PollingResponse> {
    let cmd: Command = Command.create2(CMD_POLLING, [(systemCode >> 8), (systemCode & 0xff), 0x01, 0x00]);

    let s: number[] = cmd.getBytes();
    let r: number[] = await this.transceive(s);
    let rsp: PollingResponse = new PollingResponse(r);

    this.idm = rsp.getIDm();
    this.pmm = rsp.getPMm();

    return rsp;
  }

  close() {

  }

  connect() {
    this.nfcTag.connect();
  }

  async transceive(cmdBytes?: number[], cmd?: Command): Promise<number[]> {
    if (!cmdBytes) {
      cmdBytes = cmd!.getBytes()
    }
    return await this.nfcTag.transmit(cmdBytes);
  }

  async readWithoutEncryption(addr: number, code?: ServiceCode, service?: number[]): Promise<ReadResponse> {
    if (!service) {
      if (code) {
        service = code.getBytes()
      } else {
        service = [(SRV_FELICA_LITE_READWRITE >> 8), (SRV_FELICA_LITE_READWRITE & 0xff)]
      }
    }
    let cmd: Command = Command.create3(CMD_READ_WO_ENCRYPTION, this.idm,
      [0x01, service[0], service[1], 0x01, 0x80, addr]);
    let s: number[] = cmd.getBytes();
    let r: number[] = await this.transceive(s);
    return new ReadResponse(r);
  }
}

const CMD_POLLING = 0x00;

const RSP_POLLING = 0x01;

const CMD_READ_WO_ENCRYPTION = 0x06;

const SRV_FELICA_LITE_READWRITE = 0x0900;

const STA1_NORMAL = 0x00;
