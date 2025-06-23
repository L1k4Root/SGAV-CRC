import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { REPOSITORY } from '../common/repositories/repository.token';
import {
  IVehiclesRepository,
  VehicleDTO,
} from './repositories/vehicles.repository.interface';

@Injectable()
export class VehiclesService {
  constructor(
    @Inject(REPOSITORY.VEHICLES)
    private readonly repo: IVehiclesRepository,
  ) {}

  async registerVehicle(data: VehicleDTO) {
    data.plate = data.plate.toUpperCase();
    return this.repo.create(data);
  }

  async checkAccess(plate: string) {
    const found = await this.repo.findByPlate(plate.toUpperCase());
    if (!found) throw new NotFoundException('Plate not registered');
    return found;
  }
}
