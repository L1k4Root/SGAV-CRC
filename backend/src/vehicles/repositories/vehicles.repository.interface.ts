export interface VehicleDTO {
  id?: string;
  plate: string;
  model?: string;
  color?: string;
  owner?: string;
}

export abstract class IVehiclesRepository {
  abstract findByPlate(plate: string): Promise<VehicleDTO | null>;
  abstract create(data: VehicleDTO): Promise<VehicleDTO>;
  abstract update(id: string, data: Partial<VehicleDTO>): Promise<void>;
  abstract delete(id: string): Promise<void>;
}
