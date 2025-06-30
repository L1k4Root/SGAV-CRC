import { Injectable } from '@nestjs/common';
import { execFileSync } from 'child_process';
import * as fs from 'fs';
import * as tmp from 'tmp';

@Injectable()
export class PlateScanService {
  async detectPlate(imageBuffer: Buffer): Promise<string> {
    // Write image to temp file
    const tmpObj = tmp.fileSync({ postfix: '.png' });
    fs.writeFileSync(tmpObj.name, imageBuffer);
    try {
      // Run Tesseract CLI
      const output = execFileSync('tesseract', [
        tmpObj.name,
        'stdout',
        '-l',
        'eng',
        '--oem',
        '1',
        '--psm',
        '7',
        '-c',
        'tessedit_char_whitelist=ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789',
      ]);
      return output.toString('utf8').trim();
    } finally {
      tmpObj.removeCallback();
    }
  }
}
