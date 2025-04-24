import { VehicleModel } from './VehicleModel';
import { CarType } from '../constants/car'

@ObservedV2
export class VehicleVM {
  @Trace vehicle: VehicleModel | null = null;
  private static _instance: VehicleVM;



  public static get instance() {
    if (!VehicleVM._instance) {
      VehicleVM._instance = new VehicleVM();
    }
    return VehicleVM._instance;
  }

  public addCar(carMessage: CarType) {
    this.vehicle = new VehicleModel(carMessage)
  }

  public deleteCar() {
    this.vehicle = null
  }

  public updateCarMessage(license?:string,vehiclemode?: string,mileage?: string,
    roadtime?: string,identifynumber?: string,engine?: string) {
    if (this.vehicle !== null) {
      this.vehicle.license = license;
      this.vehicle.vehiclemode = vehiclemode;
      this.vehicle.mileage = mileage;
      this.vehicle.roadtime = roadtime;
      this.vehicle.identifynumber = identifynumber;
      this.vehicle.engine = engine;
    }

  }





}