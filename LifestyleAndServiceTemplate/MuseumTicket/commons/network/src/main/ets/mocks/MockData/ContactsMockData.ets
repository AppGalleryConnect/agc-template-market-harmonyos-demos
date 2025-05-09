import { getFormattedResp } from '../Utils';
import { ContactsResp, Contacts } from '../../types/ResponseTypes';


const contacts1: Contacts = {
  personID: '1',
  name: '张三',
  cardType: '身份证',
  cardID: '110293190102291111',
  phone: '12011111111',
};

const contacts2: Contacts = {
  personID: '2',
  name: '李四',
  cardType: '身份证',
  cardID: '110293190102291112',
  phone: '12011111112',
};

const contacts3: Contacts = {
  personID: '3',
  name: '王五',
  cardType: '身份证',
  cardID: '110293190102291113',
  phone: '12011111113',
};

export class ContactsDatasetMock {
  // 常用联系人
  private static _contactsResp: ContactsResp = [
    contacts1,
    contacts2,
    contacts3,
  ];

  public static getContacts() {
    return getFormattedResp(ContactsDatasetMock._contactsResp);
  }

  public static updateContacts(data: Contacts) {
    ContactsDatasetMock._contactsResp =
      ContactsDatasetMock._contactsResp.filter((item) => item.personID !== data.personID);
    ContactsDatasetMock._contactsResp.push(data);
  }

  public static delContacts(data: string) {
    ContactsDatasetMock._contactsResp =
      ContactsDatasetMock._contactsResp.filter((item) => item.personID !== data.toString());
  }
}