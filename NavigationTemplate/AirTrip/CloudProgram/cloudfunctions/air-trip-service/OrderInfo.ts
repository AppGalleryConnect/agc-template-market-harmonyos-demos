class OrderInfo {
    id: string;
    orderNo: string;
    createTime: number;
    flightId: string;
    flightNo: string;
    airlineName: string;
    aircraftType: string;
    takeoffTime: string;
    landingTime: string;
    departureCity: string;
    departureAirport: string;
    destinationCity: string;
    destinationAirport: string;
    mealType: string;
    spaceType: string;
    spacePrice: number;
    airportConstructionPrice: number;
    fuelPrice: number;
    includeTaxPrice: number;
    contactName: string;
    contactPhone: string;
    status: number;
    passengerList: string;

    constructor() {
    }

    getFieldTypeMap():  Map<string, string> {
        let fieldTypeMap = new Map<string, string>();
        fieldTypeMap.set('id', 'String');
        fieldTypeMap.set('orderNo', 'String');
        fieldTypeMap.set('createTime', 'Long');
        fieldTypeMap.set('flightId', 'String');
        fieldTypeMap.set('flightNo', 'String');
        fieldTypeMap.set('airlineName', 'String');
        fieldTypeMap.set('aircraftType', 'String');
        fieldTypeMap.set('takeoffTime', 'String');
        fieldTypeMap.set('landingTime', 'String');
        fieldTypeMap.set('departureCity', 'String');
        fieldTypeMap.set('departureAirport', 'String');
        fieldTypeMap.set('destinationCity', 'String');
        fieldTypeMap.set('destinationAirport', 'String');
        fieldTypeMap.set('mealType', 'String');
        fieldTypeMap.set('spaceType', 'String');
        fieldTypeMap.set('spacePrice', 'Double');
        fieldTypeMap.set('airportConstructionPrice', 'Double');
        fieldTypeMap.set('fuelPrice', 'Double');
        fieldTypeMap.set('includeTaxPrice', 'Double');
        fieldTypeMap.set('contactName', 'String');
        fieldTypeMap.set('contactPhone', 'String');
        fieldTypeMap.set('status', 'Integer');
        fieldTypeMap.set('passengerList', 'Text');
        return fieldTypeMap;
    }

    getClassName(): string {
        return 'OrderInfo';
    }

    getPrimaryKeyList(): string[] {
        let primaryKeyList: string[] = [];
        primaryKeyList.push('id');
        return primaryKeyList;
    }

    getIndexList(): string[] {
        let indexList: string[] = [];
        return indexList;
    }

    getEncryptedFieldList(): string[] {
        let encryptedFieldList: string[] = [];
        return encryptedFieldList;
    }

    setId(id: string): void {
        this.id = id;
    }

    getId(): string  {
        return this.id;
    }

    setOrderNo(orderNo: string): void {
        this.orderNo = orderNo;
    }

    getOrderNo(): string  {
        return this.orderNo;
    }

    setCreateTime(createTime: number): void {
        this.createTime = createTime;
    }

    getCreateTime(): number  {
        return this.createTime;
    }

    setFlightId(flightId: string): void {
        this.flightId = flightId;
    }

    getFlightId(): string  {
        return this.flightId;
    }

    setFlightNo(flightNo: string): void {
        this.flightNo = flightNo;
    }

    getFlightNo(): string  {
        return this.flightNo;
    }

    setAirlineName(airlineName: string): void {
        this.airlineName = airlineName;
    }

    getAirlineName(): string  {
        return this.airlineName;
    }

    setAircraftType(aircraftType: string): void {
        this.aircraftType = aircraftType;
    }

    getAircraftType(): string  {
        return this.aircraftType;
    }

    setTakeoffTime(takeoffTime: string): void {
        this.takeoffTime = takeoffTime;
    }

    getTakeoffTime(): string  {
        return this.takeoffTime;
    }

    setLandingTime(landingTime: string): void {
        this.landingTime = landingTime;
    }

    getLandingTime(): string  {
        return this.landingTime;
    }

    setDepartureCity(departureCity: string): void {
        this.departureCity = departureCity;
    }

    getDepartureCity(): string  {
        return this.departureCity;
    }

    setDepartureAirport(departureAirport: string): void {
        this.departureAirport = departureAirport;
    }

    getDepartureAirport(): string  {
        return this.departureAirport;
    }

    setDestinationCity(destinationCity: string): void {
        this.destinationCity = destinationCity;
    }

    getDestinationCity(): string  {
        return this.destinationCity;
    }

    setDestinationAirport(destinationAirport: string): void {
        this.destinationAirport = destinationAirport;
    }

    getDestinationAirport(): string  {
        return this.destinationAirport;
    }

    setMealType(mealType: string): void {
        this.mealType = mealType;
    }

    getMealType(): string  {
        return this.mealType;
    }

    setSpaceType(spaceType: string): void {
        this.spaceType = spaceType;
    }

    getSpaceType(): string  {
        return this.spaceType;
    }

    setSpacePrice(spacePrice: number): void {
        this.spacePrice = spacePrice;
    }

    getSpacePrice(): number  {
        return this.spacePrice;
    }

    setAirportConstructionPrice(airportConstructionPrice: number): void {
        this.airportConstructionPrice = airportConstructionPrice;
    }

    getAirportConstructionPrice(): number  {
        return this.airportConstructionPrice;
    }

    setFuelPrice(fuelPrice: number): void {
        this.fuelPrice = fuelPrice;
    }

    getFuelPrice(): number  {
        return this.fuelPrice;
    }

    setIncludeTaxPrice(includeTaxPrice: number): void {
        this.includeTaxPrice = includeTaxPrice;
    }

    getIncludeTaxPrice(): number  {
        return this.includeTaxPrice;
    }

    setContactName(contactName: string): void {
        this.contactName = contactName;
    }

    getContactName(): string  {
        return this.contactName;
    }

    setContactPhone(contactPhone: string): void {
        this.contactPhone = contactPhone;
    }

    getContactPhone(): string  {
        return this.contactPhone;
    }

    setStatus(status: number): void {
        this.status = status;
    }

    getStatus(): number  {
        return this.status;
    }

    setPassengerList(passengerList: string): void {
        this.passengerList = passengerList;
    }

    getPassengerList(): string  {
        return this.passengerList;
    }

    static parseFrom(inputObject: any): OrderInfo {
        let result = new OrderInfo();
        if (!inputObject) {
            return result;
        }
        if (inputObject.id) {
            result.id = inputObject.id;
        }
        if (inputObject.orderNo) {
            result.orderNo = inputObject.orderNo;
        }
        if (inputObject.createTime) {
            result.createTime = inputObject.createTime;
        }
        if (inputObject.flightId) {
            result.flightId = inputObject.flightId;
        }
        if (inputObject.flightNo) {
            result.flightNo = inputObject.flightNo;
        }
        if (inputObject.airlineName) {
            result.airlineName = inputObject.airlineName;
        }
        if (inputObject.aircraftType) {
            result.aircraftType = inputObject.aircraftType;
        }
        if (inputObject.takeoffTime) {
            result.takeoffTime = inputObject.takeoffTime;
        }
        if (inputObject.landingTime) {
            result.landingTime = inputObject.landingTime;
        }
        if (inputObject.departureCity) {
            result.departureCity = inputObject.departureCity;
        }
        if (inputObject.departureAirport) {
            result.departureAirport = inputObject.departureAirport;
        }
        if (inputObject.destinationCity) {
            result.destinationCity = inputObject.destinationCity;
        }
        if (inputObject.destinationAirport) {
            result.destinationAirport = inputObject.destinationAirport;
        }
        if (inputObject.mealType) {
            result.mealType = inputObject.mealType;
        }
        if (inputObject.spaceType) {
            result.spaceType = inputObject.spaceType;
        }
        if (inputObject.spacePrice) {
            result.spacePrice = inputObject.spacePrice;
        }
        if (inputObject.airportConstructionPrice) {
            result.airportConstructionPrice = inputObject.airportConstructionPrice;
        }
        if (inputObject.fuelPrice) {
            result.fuelPrice = inputObject.fuelPrice;
        }
        if (inputObject.includeTaxPrice) {
            result.includeTaxPrice = inputObject.includeTaxPrice;
        }
        if (inputObject.contactName) {
            result.contactName = inputObject.contactName;
        }
        if (inputObject.contactPhone) {
            result.contactPhone = inputObject.contactPhone;
        }
        if (inputObject.status) {
            result.status = inputObject.status;
        }
        if (inputObject.passengerList) {
            result.passengerList = inputObject.passengerList;
        }
        return result;
    }
}

export { OrderInfo };