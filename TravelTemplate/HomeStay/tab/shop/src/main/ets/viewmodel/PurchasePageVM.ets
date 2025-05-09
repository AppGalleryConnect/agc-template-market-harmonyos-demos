import { CreateOrderRequest, https } from 'network';

export async function createOrder(data: CreateOrderRequest) {
  return https.createOrder(data);
}