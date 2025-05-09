@Observed
export class Passenger {
  id: string;
  name?: string;
  phone?: string;
  cardType?: number;
  cardNo?: string;

  constructor(
    id: string = '1',
    name: string = '张耳',
    phone: string = '18264375988',
    cardType: number = 1,
    cardNo: string = '32353490583468369369',
  ) {
    this.id = id;
    this.name = name;
    this.phone = phone;
    this.cardType = cardType;
    this.cardNo = cardNo;
  }
}

class PassengerBasicDataSource implements IDataSource {
  private listeners: DataChangeListener[] = [];
  private originDataArray: Passenger[] = [];

  public totalCount(): number {
    return 0;
  }

  public getData(index: number): Passenger {
    return this.originDataArray[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }

  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    });
  }

  notifyDataAdd(index: number, count: number): void {
    this.listeners.forEach(listener => {
      listener.onDatasetChange([{ type: DataOperationType.ADD, index, count }]);
    });
  }

  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    });
  }

  notifyDataDelete(index: number, count: number): void {
    this.listeners.forEach(listener => {
      listener.onDatasetChange([{ type: DataOperationType.DELETE, index, count }]);
    });
  }

  notifyDataMove(from: number, to: number): void {
    this.listeners.forEach(listener => {
      listener.onDataMove(from, to);
    });
  }
}

export class PassengerDataSource extends PassengerBasicDataSource {
  private dataArray: Passenger[] = [
    new Passenger('1'),
    new Passenger('2'),
    new Passenger('3'),
    new Passenger('4'),
    new Passenger('5'),
    new Passenger('6'),
    new Passenger('7'),
    new Passenger('8'),
    new Passenger('9'),
    new Passenger('10'),
  ];

  public totalCount(): number {
    return this.dataArray.length;
  }

  public getData(index: number): Passenger {
    return this.dataArray[index];
  }

  public addData(index: number, data: Passenger[]): void {
    this.dataArray.splice(index, 0, ...data);
    this.notifyDataAdd(index, data.length);
  }

  public pushData(data: Passenger): void {
    this.dataArray.push(data);
    this.notifyDataAdd(this.dataArray.length - 1, 1);
  }

  public deleteData(index: number): void {
    this.dataArray.splice(index, 1);
    this.notifyDataDelete(index, 1);
  }

  public refreshList(): void {
    this.dataArray.splice(0, this.dataArray.length);
    this.notifyDataDelete(0, this.dataArray.length);
    for (let index = 0; index < 10; index++) {
      this.pushData(new Passenger(index.toString()));
    }
  }
}