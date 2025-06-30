import { Test, TestingModule } from '@nestjs/testing';
import { PlateScanController } from './plate-scan.controller';

describe('PlateScanController', () => {
  let controller: PlateScanController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [PlateScanController],
    }).compile();

    controller = module.get<PlateScanController>(PlateScanController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
