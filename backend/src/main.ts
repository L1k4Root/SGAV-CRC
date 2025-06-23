import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { FirebaseAuthGuard } from './common/guards/firebase-auth.guard';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableCors({ origin: '*' });
  // 🔒 temporalmente hasta que se domine el token
  // app.useGlobalGuards(new FirebaseAuthGuard(app.get(Reflector)));
  await app.listen(3000);
}
bootstrap();
