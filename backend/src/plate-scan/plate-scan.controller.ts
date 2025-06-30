import {
  Controller,
  Post,
  UseInterceptors,
  UploadedFile,
  BadRequestException,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { PlateScanService } from './plate-scan.service';

@Controller('scan-plate')
export class PlateScanController {
  constructor(private readonly plateSvc: PlateScanService) {}

  @Post()
  @UseInterceptors(FileInterceptor('image'))
  async scan(@UploadedFile() file: Express.Multer.File) {
    console.log('Received scan-plate request at', new Date().toISOString());
    if (!file) throw new BadRequestException('No image received');

    // Use Tesseract CLI to detect text
    const plate = await this.plateSvc.detectPlate(file.buffer);
    if (!plate) throw new BadRequestException('Plate not detected');
    return { plate };
  }
}
