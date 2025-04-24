import { ContactModel, CONTACT_DEFAULT } from './ContactModel';

@ObservedV2
export class ContactVM {
  @Trace contactList: ContactModel[] = [];
  @Trace selectContact: ContactModel | undefined = undefined;
  private static _instance: ContactVM;

  public static get instance() {
    if (!ContactVM._instance) {
      ContactVM._instance = new ContactVM();
    }
    return ContactVM._instance;
  }

  constructor() {
    this.contactList = [...CONTACT_DEFAULT];
    if (this.contactList.length > 0) {
      this.selectContact =  this.contactList.find((item:ContactModel) => item.choosen);
    }
  }

  public addContact(product: ContactModel) {
    const hasAdd: boolean = this.contactList.some((item: ContactModel) => product.contactNumber === item.contactNumber);
    if (!hasAdd) {
      this.contactList.push(product);
    }
  }

  public removeContact(product: ContactModel) {
    const index = this.contactList.findIndex((item: ContactModel) => item.contactNumber === product.contactNumber);
    if (index !== -1) {
      this.contactList.splice(index, 1);
    }
  }

  public setChoosen(product: ContactModel) {
    this.contactList.forEach((item:ContactModel)=>{
      if(item.contactNumber===product.contactNumber){
        item.choosen=true;
      }else {
        item.choosen=false;
      }
    })
  }

  public getCurrentContact():ContactModel | undefined {
    if  (this.selectContact !== undefined) {
      return this.selectContact;
    }
    return this.contactList.find((item:ContactModel) => item.choosen)
  }

  public setSelectContact(contact:ContactModel) {
    this.selectContact = contact;
  }

  public clearSelectContact() {
    this.selectContact = undefined;
  }
}