import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { VehiclesModule } from './vehicles/vehicles.module';
import { AccessModule } from './access/access.module';
import { IncidentsModule } from './incidents/incidents.module';

@Module({
  imports: [AuthModule, UsersModule, VehiclesModule, AccessModule, IncidentsModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
