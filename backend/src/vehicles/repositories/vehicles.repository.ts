import { Injectable } from '@nestjs/common';
import { db } from '../../firebase'; // tu init de Admin SDK
import {
  IVehiclesRepository,
  VehicleDTO,
} from './vehicles.repository.interface';

@Injectable()
export class VehiclesFirestoreRepository implements IVehiclesRepository {
  private readonly col = db.collection('vehicles');

  async findByPlate(plate: string): Promise<VehicleDTO | null> {
    const snap = await this.col.where('plate', '==', plate).limit(1).get();
    if (snap.empty) return null;
    return { id: snap.docs[0].id, ...snap.docs[0].data() } as VehicleDTO;
  }

  async create(data: VehicleDTO): Promise<VehicleDTO> {
    const ref = await this.col.add(data);
    return { id: ref.id, ...data };
  }

  async update(id: string, data: Partial<VehicleDTO>): Promise<void> {
    await this.col.doc(id).update(data);
  }

  async delete(id: string): Promise<void> {
    await this.col.doc(id).delete();
  }
}
