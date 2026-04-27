import { tag } from '@kit.ConnectivityKit'
import Util from '../../../Util'
import NFC from '../../Nfc';

export class Iso7816 {
  static EMPTY = [0]
  data: number[]

  constructor(bytes: number[] = Iso7816.EMPTY) {
    this.data = bytes
  }

  matchShort(tag: number): boolean {
    if (this.data.length === 2) {
      let d0 = 0x000000FF & (tag >> 8)
      let d1 = 0x000000FF & tag
      return (this.data[0] === d0 && this.data[1] === d1);
    }
    return (tag >= 0 && tag <= 255) ? this.matchByte(tag) : false;
  }

  matchByte(tag: number): boolean {
    return this.data.length !== 1 || this.data[0] !== tag
  }

  matchBytes(bytes: number[], start: number = 0): boolean {
    if (this.data.length <= bytes.length - start) {
      for (let v of this.data) {
        if (v !== bytes[start++]) {
          return false
        }
      }
    } else {
      return false
    }
    return true
  }

  size(): number {
    return this.data.length
  }

  getBytes(start?: number, end?: number): number[] {
    return this.data.slice(start, end)
  }

  toInt(): number {
    return Util.toInt(this.data)
  }

  toIntR(): number {
    return Util.toIntR(this.data);
  }

  toString(): string {
    return Util.toHexString(this.data)
  }

  equal(obj: object): boolean {
    if (this === obj) {
      return true
    }
    if (obj != null && obj instanceof Iso7816) {
      return this.matchBytes((obj as Iso7816).getBytes())
    }
    return false
  }
}

export class ID extends Iso7816 {
  constructor(bytes: number[]) {
    super(bytes)
  }
}

export class Response extends Iso7816 {
  static EMPTY: number[] = [];
  static ERROR: number[] = [0x6F, 0x00]; // SW_UNKNOWN
  constructor(bytes: number[]) {
    super((bytes === null || bytes.length < 2) ? Response.ERROR : bytes)
  }


  getSw1(): number {
    return this.data[this.data.length - 2];
  }

  getSw2(): number {
    return this.data[this.data.length - 1];
  }

  getSw12String(): string {
    let sw1 = this.getSw1() & 0x000000FF;
    let sw2 = this.getSw2() & 0x000000FF;

    return '0x' + Util.toHexString([sw1, sw2])
  }

  getSw12(): number {
    let n = this.data.length;
    return (this.data[n - 2] << 8) | (0xFF & this.data[n - 1]);
  }

  isOkay(): boolean {
    return this.equalsSw12(SW_NO_ERROR);
  }

  equalsSw12(val: number): boolean {
    return this.getSw12() === val;
  }

  size(): number {
    return this.data.length - 2;
  }

  getBytes(): number[] {
    return this.isOkay() ? this.data.slice(0, this.size()) : Response.EMPTY
  }
}

export class MifareDResponse extends Response {
  constructor(bytes: number[]) {
    super(bytes)
  }
}

export class BerT extends Iso7816 {
  // tag template
  static TMPL_FCP = 0x62; // File Control Parameters
  static TMPL_FMD = 0x64; // File Management Data
  static TMPL_FCI = 0x6F; // FCP and FMD

  // proprietary information
  static CLASS_PRI = new BerT([0xA5]);
  // short EF identifier
  static CLASS_SFI = new BerT([0x88]);
  // dedicated file name
  static CLASS_DFN = new BerT([0x84]);
  // application data object
  static CLASS_ADO = new BerT([0x61]);
  // application id
  static CLASS_AID = new BerT([0x4F]);

  static test(bytes: number[], start: number): number {
    let len = 1;
    if ((bytes[start] & 0x1F) === 0x1F) {
      while ((bytes[start + len] & 0x80) === 0x80) {
        ++len;
      }
      ++len;
    }
    return len;
  }

  static read(bytes: number[], start: number): BerT {
    return new BerT(bytes.slice(start, start + BerT.test(bytes, start)));
  }

  static createByShort(tag: number): BerT {
    return new BerT([(0x000000FF & (tag >> 8)), (0x000000FF & tag)])
  }

  constructor(bytes: number[]) {
    super(bytes)
  }

  hasChild(): boolean {
    return ((this.data[0] & 0x20) === 0x20);
  }

  toShort(): number {
    if (this.size() <= 2) {
      return Util.toInt(this.data);
    }
    return 0;
  }
}

export class BerL extends Iso7816 {
  value: number

  static test(bytes: number[], start: number): number {
    let len = 1;
    if ((bytes[start] & 0x80) === 0x80) {
      len += bytes[start] & 0x07;
    }
    return len;
  }

  static calc(bytes: number[], start: number): number {
    if ((bytes[start] & 0x80) === 0x80) {
      let v = 0;
      let e = start + bytes[start] & 0x07;
      while (++start <= e) {
        v <<= 8;
        v |= bytes[start] & 0xFF;
      }
      return v;
    }

    return bytes[start];
  }

  static read(bytes: number[], start: number): BerL {
    return new BerL(bytes.slice(start, start + BerL.test(bytes, start)));
  }

  static create(len: number): BerL {
    return new BerL(undefined, len)
  }

  constructor(bytes?: number[], value?: number) {
    super(bytes)
    this.value = value ? value : BerL.calc(bytes!, 0);
  }

  toInt(): number {
    return this.value;
  }
}


export class BerV extends Iso7816 {
  static read(bytes: number[], start: number, len: number): BerV {
    return new BerV(bytes.slice(start, start + len));
  }

  constructor(bytes: number[]) {
    super(bytes)
  }
}

export class BerTLV extends Iso7816 {
  static test(bytes: number[], start: number): number {
    let lt = BerT.test(bytes, start);
    let ll = BerL.test(bytes, start + lt);
    let lv = BerL.calc(bytes, start + lt);
    return lt + ll + lv;
  }

  static getValue(tlv: BerTLV): number[] | undefined {
    if (tlv === null || tlv.length() === 0) {
      return undefined;
    }

    return tlv.v!.getBytes();
  }

  static read(obj?: Iso7816, bytes?: number[], start?: number): BerTLV {
    if (!bytes) {
      bytes = obj?.getBytes()
    }
    if (!start) {
      start = 0
    }
    let s = start;
    let t = BerT.read(bytes!, s);
    s += t.size();
    let l = BerL.read(bytes!, s);
    s += l.size();
    let v = BerV.read(bytes!, s, l.toInt());
    s += v.size();
    let tlv = new BerTLV(t, l, v);
    tlv.data = bytes!.slice(start, s);
    return tlv;
  }


  static extractChildren(out: BerTLV[], obj?: Iso7816, data?: number[]) {
    if (!data) {
      data = obj?.getBytes()
    }
    let start: number = 0;
    let end = data!.length - 3;
    while (start <= end) {
      let tlv = BerTLV.read(undefined, data!, start);
      out.push(tlv);
      start += tlv.size();
    }
  }

  static extractPrimitives(house?: BerHouse, out?: BerTLV[], obj?: Iso7816, data?: number[]) {
    if (!out) {
      out = house!.tlvs
    }
    if (!data) {
      data = obj!.getBytes()
    }

    let start: number = 0;
    let end = data.length - 3;
    while (start <= end) {
      let tlv = BerTLV.read(undefined, data, start);
      if (tlv.t.hasChild()) {
        BerTLV.extractPrimitives(undefined, out, undefined, tlv.v!.getBytes());
      } else {
        out.push(tlv);
      }

      start += tlv.size();
    }
  }

  static extractOptionList(data: number[]): BerTLV[] {
    let ret: BerTLV[] = [];

    let start: number = 0;
    let end = data.length;
    while (start < end) {
      let t = BerT.read(data, start);
      start += t.size();

      if (start < end) {
        let l = BerL.read(data, start);
        start += l.size();

        if (start <= end) {
          ret.push(new BerTLV(t, l, undefined));
        }
      }
    }

    return ret;
  }

  t: BerT;
  l: BerL;
  v?: BerV;

  constructor(t: BerT, l: BerL, v?: BerV) {
    super(undefined)
    this.t = t
    this.l = l
    this.v = v
  }

  length(): number {
    return this.l.toInt();
  }
}

export class BerHouse {
  tlvs: BerTLV[] = [];

  count(): number {
    return this.tlvs.length;
  }

  add(tag: number, t?: BerT, response?: Response, v?: number[], tlv?: BerTLV) {
    if (!t) {
      t = BerT.createByShort(tag)
    }
    if (!v) {
      v = response!.getBytes()
    }
    if (!tlv) {
      tlv = new BerTLV(t, BerL.create(v.length), new BerV(v))
    }
    this.tlvs.push(tlv);
  }

  get(index: number): BerTLV {
    return this.tlvs[index];
  }

  findFirst(tagByte?: number, tagSort?: number, tag?: BerT, tagBytes?: number[]): BerTLV | undefined {
    if (tagByte) {
      for (let tlv of this.tlvs) {
        if (tlv.t.matchByte(tagByte)) {
          return tlv;
        }
      }
    } else if (tagSort) {
      for (let tlv of this.tlvs) {
        if (tlv.t.matchShort(tagSort)) {
          return tlv;
        }
      }
    } else {
      if (!tagBytes) {
        tagBytes = tag?.getBytes()
      }
      for (let tlv of this.tlvs) {
        if (tlv.t.matchBytes(tagBytes!)) {
          return tlv;
        }
      }
    }
    return undefined;
  }

  findAll(tagByte?: number, tagShort?: number, tag?: BerT, tagBytes?: number[]): BerTLV[] {
    let ret: BerTLV[] = [];
    if (tagByte) {

      for (let tlv of this.tlvs) {
        if (tlv.t.matchByte(tagByte)) {
          ret.push(tlv)
        }
      }
    } else if (tagShort) {
      for (let tlv of this.tlvs) {
        if (tlv.t.matchShort(tagShort)) {
          ret.push(tlv)
        }
      }
    } else {
      if (!tagBytes) {
        tagBytes = tag!.getBytes()
      }
      for (let tlv of this.tlvs) {
        if (tlv.t.matchBytes(tagBytes)) {
          ret.push(tlv)
        }
      }
    }
    return ret;
  }

  toString(): string {
    let ret = '';
    for (let t of this.tlvs) {
      ret = ret + t.t.toString() + ' ';
      ret = ret + t.l.toInt() + ' ';
      ret = ret + t.v!.toString() + '\n';

    }
    return ret;
  }
}

export class StdTag {
  nfcTag: tag.IsoDepTag;
  id: ID

  constructor(isoDeepTag: tag.IsoDepTag) {
    this.nfcTag = isoDeepTag
    this.id = new ID(tag.getTagInfo(NFC.startWant).uid);
  }

  getID(): ID {
    return this.id
  }

  async getBalance(p1: number, isEP: boolean): Promise<Response> {
    let cmd = [0x80, // CLA Class
      0x5C, // INS Instruction
      p1, // P1 Parameter 1
      (isEP ? 2 : 1), // P2 Parameter 2
      0x04,// Le
    ]
    return new Response(await this.transceive(cmd));
  }

  async readRecord(sfi: number, index?: number): Promise<Response> {
    let cmd: number[] = [
      0x00, // CLA Class
      0xB2, // INS Instruction
      index ? index : 0x01, // P1 Parameter 1
      ((sfi << 3) | (index ? 0x04 : 0x05)), // P2 Parameter 2
      0x00,// Le
    ]
    return new Response(await this.transceive(cmd));
  }

  async readBinary(sfi: number): Promise<Response> {
    let cmd = [
      0x00, // CLA Class
      0xB0, // INS Instruction
      (0x00000080 | (sfi & 0x1F)), // P1 Parameter 1
      0x00, // P2 Parameter 2
      0x00,// Le
    ];
    return new Response(await this.transceive(cmd));
  }

  async readData(sfi?: number, tagShort?: number): Promise<Response> {
    let cmd: number[] = []
    if (sfi) {
      let cmd = [
        0x80, // CLA Class
        0xCA, // INS Instruction
        0x00, // P1 Parameter 1
        (sfi & 0x1F), // P2 Parameter 2
        0x00,// Le
      ]
    } else if (tagShort) {
      let cmd = [
        0x80, // CLA Class
        0xCA, // INS Instruction
        ((tagShort >> 8) & 0xFF), // P1 Parameter 1
        (tagShort & 0x1F), // P2 Parameter 2
        0x00, // Lc
        0x00,// Le
      ];
    }
    return new Response(await this.transceive(cmd));
  }

  async getData(tagShort: number): Promise<Response> {
    let cmd = [
      0x80, // CLA Class
      0xCA, // INS Instruction
      ((tagShort >> 8) & 0xFF), (tagShort & 0xFF),
      0x00,// Le
    ];
    return new Response(await this.transceive(cmd));
  }

  async selectByID(id: number[]): Promise<Response> {
    let buff: number[] = []
    buff.push(0x00) // CLA Class
    buff.push(0xA4) // INS Instruction
    buff.push(0x00) // P1 Parameter 1
    buff.push(0x00) // P2 Parameter 2
    buff.push(id.length) // Lc
    for (let idElement of id) {
      buff.push(idElement)
    }
    buff.push(0x00); // Le
    return new Response(await this.transceive(buff));
  }

  async selectByName(name: number[]): Promise<Response> {
    let buff: number[] = [];
    buff.push(0x00) // CLA Class
    buff.push(0xA4) // INS Instruction
    buff.push(0x04) // P1 Parameter 1
    buff.push(0x00) // P2 Parameter 2
    buff.push(name.length) // Lc
    for (let nameElement of name) {
      buff.push(nameElement)
    }
    buff.push(0x00); // Le
    return new Response(await this.transceive(buff));
  }

  async getProcessingOptions(pdol: number[]): Promise<Response> {
    let buff: number[] = [];
    buff.push(0x80) // CLA Class
    buff.push(0xA8) // INS Instruction
    buff.push(0x00) // P1 Parameter 1
    buff.push(0x00) // P2 Parameter 2
    buff.push(pdol.length) // Lc
    for (let pdolElement of pdol) {
      buff.push(pdolElement)
    }
    buff.push(0x00); // Le
    return new Response(await this.transceive(buff));
  }

  connect() {
    this.nfcTag.connect();
  }

  async transceive(cmd: number[]): Promise<number[]> {
    let rsp: number[] = [];

    let c: number[] = cmd;
    do {
      let r: number[] = await this.nfcTag.transmit(c)
      if (r == null) {
        break;
      }

      let N = r.length - 2;
      if (N < 0) {
        rsp = r;
        break;
      }

      if (r[N] === StdTag.CH_STA_LE) {
        c[c.length - 1] = r[N + 1];
        continue;
      }

      if (rsp == null) {
        rsp = r;
      } else {
        let n = rsp.length;
        N += n;

        rsp.slice(0, N)

        rsp = Util.copyOf(rsp, N);

        n -= 2;

        for (let i of r) {
          rsp[n++] = i;
        }
      }

      if (r[N] !== StdTag.CH_STA_MORE) {
        break;
      }

      let s = r[N + 1];
      if (s !== 0) {
        c = StdTag.CMD_GETRESPONSE.slice();
      } else {
        rsp[rsp.length - 1] = StdTag.CH_STA_OK;
        break;
      }

    } while (true);

    return rsp;

  }

  static CH_STA_OK: number = 0x90;
  static CH_STA_MORE: number = 0x61;
  static CH_STA_LE: number = 0x6C;
  static CMD_GETRESPONSE: number[] = [0, 0xC0, 0, 0, 0,];
}

const SW_NO_ERROR: number = 0x9000;