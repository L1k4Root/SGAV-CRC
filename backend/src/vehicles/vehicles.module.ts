import { Module } from '@nestjs/common';
import { VehiclesController } from './vehicles.controller';
import { VehiclesService } from './vehicles.service';
import { VehiclesFirestoreRepository } from './repositories/vehicles.repository';
import { REPOSITORY } from '../common/repositories/repository.token';

@Module({
  controllers: [VehiclesController],
  providers: [
    VehiclesService,
    {
      provide: REPOSITORY.VEHICLES, // token
      useClass: VehiclesFirestoreRepository,
    },
  ],
  exports: [REPOSITORY.VEHICLES], // por si otro módulo necesita inyectarlo
})
export class VehiclesModule {}
