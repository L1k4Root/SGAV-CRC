import { Controller, Get, Post, Query, Body } from '@nestjs/common';
import { VehiclesService } from './vehicles.service';

@Controller('vehicles')
export class VehiclesController {
  constructor(private readonly svc: VehiclesService) {}

  @Get()
  async find(@Query('plate') plate: string) {
    return await this.svc.findByPlate(plate.toUpperCase());
  }

  @Post()
  async create(@Body() dto: any) {
    dto.plate = dto.plate.toUpperCase();
    return this.svc.addVehicle(dto);
  }
}
