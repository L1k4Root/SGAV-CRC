import {
  Injectable,
  CanActivate,
  ExecutionContext,
  UnauthorizedException,
} from '@nestjs/common';
import { getAuth } from 'firebase-admin/auth';

@Injectable()
export class FirebaseAuthGuard implements CanActivate {
  async canActivate(ctx: ExecutionContext): Promise<boolean> {
    const req = ctx.switchToHttp().getRequest();
    const auth = req.headers.authorization?.split('Bearer ')[1];
    if (!auth) throw new UnauthorizedException('Missing token');

    try {
      const decoded = await getAuth().verifyIdToken(auth);
      req.user = decoded; // uid, email, etc. disponible en los handlers
      return true;
    } catch (_) {
      throw new UnauthorizedException('Invalid token');
    }
  }
}
