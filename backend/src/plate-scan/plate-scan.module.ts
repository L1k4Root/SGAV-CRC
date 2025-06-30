import { Module } from '@nestjs/common';
import { PlateScanController } from './plate-scan.controller';
import { PlateScanService } from './plate-scan.service';

@Module({
  controllers: [PlateScanController],
  providers: [PlateScanService],
})
export class PlateScanModule {}
