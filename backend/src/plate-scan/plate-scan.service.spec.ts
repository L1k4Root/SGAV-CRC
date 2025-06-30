import { Test, TestingModule } from '@nestjs/testing';
import { PlateScanService } from './plate-scan.service';

describe('PlateScanService', () => {
  let service: PlateScanService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [PlateScanService],
    }).compile();

    service = module.get<PlateScanService>(PlateScanService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
