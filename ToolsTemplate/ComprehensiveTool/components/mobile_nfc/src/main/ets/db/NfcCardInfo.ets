import sql from '@liushengyi/smartdb';
import { HashSet } from '@kit.ArkTS';
import { NFC_TYPE } from '../common/Enum';

export class NfcInfo {
  @sql.SqlColumn(sql.ColumnType.INTEGER)
  id?: number;
  //卡片ID
  @sql.SqlColumn(sql.ColumnType.TEXT)
  cardId: string;
  //卡片名称
  @sql.SqlColumn(sql.ColumnType.TEXT)
  name: string;
  //卡片类型
  @sql.SqlColumn(sql.ColumnType.INTEGER)
  type: number;

  @sql.SqlColumn(sql.ColumnType.INTEGER)
  dataSize: number; //内存大小
  @sql.SqlColumn(sql.ColumnType.INTEGER)
  section: number; //扇区数
  @sql.SqlColumn(sql.ColumnType.INTEGER)
  blocks: number; //总块数
  @sql.SqlColumn(sql.ColumnType.TEXT)
  sectionInfo: string; //扇区详情 List<String[]> string,string,string

  @sql.SqlColumn(sql.ColumnType.FLOAT)
  balance: number; //余额float
  @sql.SqlColumn(sql.ColumnType.TEXT)
  city: string; //城市
  @sql.SqlColumn(sql.ColumnType.TEXT)
  issuing: string; //发行日期
  @sql.SqlColumn(sql.ColumnType.TEXT)
  effective: string; //有效日期
  @sql.SqlColumn(sql.ColumnType.TEXT)
  dealHistory: string; //交易记录 List<DealHistory>
  //    private String com;//通信日志
  @sql.SqlColumn(sql.ColumnType.FLOAT)
  ltime: number; //最后扫描时间 long
  @sql.SqlColumn(sql.ColumnType.BOOL)
  historyDel: boolean; //历史记录删除
  @sql.SqlColumn(sql.ColumnType.BOOL)
  isMine: boolean; //是我的卡片

  constructor(id?: number, cardId?: string, name?: string, type?: number, dataSize?: number
    , section?: number, blocks?: number, sectionInfo?: string, balance?: number, city?: string, issuing?: string,
    effective?: string, dealHistory?: string, ltime?: number, historyDel?: boolean, isMine?: boolean) {
    this.id = id;
    this.cardId = cardId ? cardId : '';
    this.name = name ? name : '';
    this.type = type ? type : NFC_TYPE.NFC_TYPE_DOOR;
    this.dataSize = dataSize ? dataSize : 0;
    this.section = section ? section : 0;
    this.blocks = blocks ? blocks : 0;
    this.sectionInfo = sectionInfo ? sectionInfo : '';
    this.balance = balance ? balance : -1;
    this.city = city ? city : '';
    this.issuing = issuing ? issuing : '';
    this.effective = effective ? effective : '';
    this.dealHistory = dealHistory ? dealHistory : '';
    this.ltime = ltime ? ltime : new Date().getTime();
    this.historyDel = historyDel ? historyDel : false;
    this.isMine = isMine ? isMine : false;
  }
}

export const NFC_DB_NAME = 'db_nfc';

class NfcCardInfo {
  constructor() {
  }

  @sql.Sql('create table if not exists ' + NFC_DB_NAME + ' ( ' +
    'id INTEGER PRIMARY KEY AUTOINCREMENT ,' +
    'cardId TEXT ,' +
    'name TEXT ,' +
    'type INTEGER ,' +
    'dataSize INTEGER ,' +
    'section INTEGER ,' +
    'blocks INTEGER ,' +
    'sectionInfo TEXT ,' +
    'balance FLOAT ,' +
    'city TEXT ,' +
    'issuing TEXT ,' +
    'effective TEXT ,' +
    'dealHistory TEXT ,' +
    'ltime FLOAT ,' +
    'historyDel BOOL ,' +
    'isMine BOOL ' +
    ')')
  createDb(): Promise<void> {
    return sql.PromiseNull();
  }

  @sql.SqlQuery('select * from db_nfc where id=#{id}')
  @sql.ReturnType(NfcInfo)
  findById(@sql.Param('id') id: number): Promise<NfcInfo> {
    return sql.PromiseNull();
  }

  @sql.SqlQuery('select * from db_nfc where name=#{name}')
  @sql.ReturnType(NfcInfo)
  findByName(@sql.Param('name') name: string): Promise<NfcInfo> {
    return sql.PromiseNull();
  }

  @sql.SqlInsert('replace into db_nfc (cardId,name,type,dataSize,section,blocks,sectionInfo,balance,city,issuing,' +
    'effective,dealHistory,ltime,historyDel,isMine) values ' +
    '(#{nfcInfo.cardId},#{nfcInfo.name},#{nfcInfo.type},#{nfcInfo.dataSize},#{nfcInfo.section},#{nfcInfo.blocks},' +
    '#{nfcInfo.sectionInfo},#{nfcInfo.balance},#{nfcInfo.city},#{nfcInfo.issuing},#{nfcInfo.effective},#{nfcInfo.dealHistory},' +
    '#{nfcInfo.ltime},#{nfcInfo.historyDel},#{nfcInfo.isMine}) ',
  { table: 'db_nfc', id: 'id' })
  insertNfcInfo(@sql.Param('nfcInfo') nfcInfo: NfcInfo): Promise<number> {
    return sql.PromiseNull();
  }

  @sql.SqlInsert('replace into db_nfc (id,cardId,name,type,dataSize,section,blocks,sectionInfo,balance,city,issuing,' +
    'effective,dealHistory,ltime,historyDel,isMine) values ' +
    '(#{nfcInfo.id},#{nfcInfo.cardId},#{nfcInfo.name},#{nfcInfo.type},#{nfcInfo.dataSize},#{nfcInfo.section},#{nfcInfo.blocks},' +
    '#{nfcInfo.sectionInfo},#{nfcInfo.balance},#{nfcInfo.city},#{nfcInfo.issuing},#{nfcInfo.effective},#{nfcInfo.dealHistory},' +
    '#{nfcInfo.ltime},#{nfcInfo.historyDel},#{nfcInfo.isMine}) ')
  updateNfcInfo(@sql.Param('nfcInfo') nfcInfo: NfcInfo): Promise<void> {
    return sql.PromiseNull();
  }

  @sql.SqlQuery('select * from db_nfc where historyDel=false ')
  @sql.ReturnListType(NfcInfo)
  findAllWithHistory(): Promise<Array<NfcInfo>> {
    return sql.PromiseNull();
  }

  @sql.SqlQuery('select * from db_nfc where isMine=true AND type=#{nfcType} ')
  @sql.ReturnListType(NfcInfo)
  findAllWithMine(@sql.Param('nfcType') nfcType: number): Promise<Array<NfcInfo>> {
    return sql.PromiseNull();
  }

  deleteNfcInfo(nfcInfo: NfcInfo, history: boolean): Promise<void> {
    if (history) { //history
      if (nfcInfo.isMine) {
        nfcInfo.historyDel = true;
        return this.updateNfcInfo(nfcInfo);
      } else {
        return this.deleteNfc(nfcInfo);
      }
    } else { //mine
      if (nfcInfo.historyDel) {
        return this.deleteNfc(nfcInfo);
      } else {
        nfcInfo.isMine = false;
        return this.updateNfcInfo(nfcInfo);
      }
    }
  }

  @sql.Transactional()
  async deleteNfcInfoByIds(ids: HashSet<number>, history: boolean): Promise<void> {
    for (let idsElement of ids) {
      let nfcInfo = await this.findById(idsElement);
      if (history) { //history
        if (nfcInfo.isMine) {
          nfcInfo.historyDel = true;
          await this.updateNfcInfo(nfcInfo);
        } else {
          await this.deleteNfc(nfcInfo);
        }
      } else { //mine
        if (nfcInfo.historyDel) {
          await this.deleteNfc(nfcInfo);
        } else {
          nfcInfo.isMine = false;
          await this.updateNfcInfo(nfcInfo);
        }
      }
    }
    return;
  }

  @sql.SqlDelete('delete from db_nfc where id=#{nfcInfo.id}')
  private deleteNfc(@sql.Param('nfcInfo') nfcInfo: NfcInfo): Promise<void> {
    return sql.PromiseNull();
  }

  @sql.SqlDelete('delete from db_nfc where id=#{id}')
  private deleteNfcById(@sql.Param('id') id: number): Promise<void> {
    return sql.PromiseNull();
  }

  @sql.SqlInsert('replace into db_nfc (name,type,dataSize,section,blocks,sectionInfo,ltime,historyDel,isMine) values ' +
    '(#{name}, #{type}, #{dataSize}, #{section}, #{blocks}, #{sectionInfo}, #{ltime}, #{historyDel}, #{isMine}) ',
  { table: 'db_nfc', id: 'id' })
  insertNfc(@sql.Param('nfcInfo') cardId: string, @sql.Param('name') name: string, @sql.Param('type') type: number,
    @sql.Param('dataSize') dataSize: number, @sql.Param('section') section: number, @sql.Param('blocks') blocks: number,
    @sql.Param('sectionInfo') sectionInfo: string, @sql.Param('ltime') ltime: number,
    @sql.Param('historyDel') historyDel: boolean, @sql.Param('isMine') isMine: boolean): Promise<number> {
    return sql.PromiseNull();
  }

  @sql.SqlInsert('replace into db_nfc (name) values (#{name}) ',{ table: 'db_nfc', id: 'id' })
  insertReturnRowId(data: NfcInfo): Promise<number> {
    return sql.PromiseNull();
  }

  @sql.SqlInsert('replace into db_nfc (id,name) values (#{id},#{name}) ')
  insert(@sql.Param('id') id: number, @sql.Param('name') name: string): Promise<void> {
    return sql.PromiseNull();
  }

  @sql.SqlInsert('replace into db_nfc (id,name) values (#{user.id},#{user.name}) ')
  insertUser(@sql.Param('user') user: NfcInfo): Promise<void> {
    return sql.PromiseNull();
  }

  @sql.SqlQuery('select * from db_nfc where id=#{id}')
  @sql.ReturnType(NfcInfo)
  findUser(@sql.Param('id') id: number): Promise<NfcInfo> {
    return sql.PromiseNull();
  }

  @sql.SqlQuery('select * from db_nfc')
  @sql.ReturnType([NfcInfo])
  findAll(): Promise<Array<NfcInfo>> {
    return sql.PromiseNull();
  }

  @sql.SqlQuery('select id from db_nfc')
  @sql.ReturnType([Number])
  findAllIds(): Promise<Array<number>> {
    return sql.PromiseNull();
  }

  @sql.SqlQuery('select count(*) from db_nfc')
  @sql.ReturnType(Number)
  findAllCount(): Promise<Number> {
    return sql.PromiseNull();
  }

  @sql.SqlDelete('delete from db_nfc ')
  deleteAll(): Promise<void> {
    return sql.PromiseNull();
  }

  @sql.SqlQuery('select * from db_nfc where #{cond} ')
  @sql.ReturnListType(NfcInfo)
  searchUser(@sql.Param('cond',true) cond: string): Promise<Array<NfcInfo>> {
    return sql.PromiseNull();
  }
}

export const nfcCardInfo = new NfcCardInfo;