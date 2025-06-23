import {
  Injectable,
  CanActivate,
  ExecutionContext,
  UnauthorizedException,
  ForbiddenException,
} from '@nestjs/common';
import { getAuth } from 'firebase-admin/auth';
import { Reflector } from '@nestjs/core';
import { ROLES_KEY } from '../decorators/roles.decorator';

@Injectable()
export class FirebaseAuthGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  async canActivate(ctx: ExecutionContext): Promise<boolean> {
    const req = ctx.switchToHttp().getRequest();
    const auth = req.headers.authorization?.split('Bearer ')[1];
    if (!auth) throw new UnauthorizedException('Missing token');

    try {
      const decoded = await getAuth().verifyIdToken(auth);
      const allowed = this.reflector.get<string[]>(ROLES_KEY, ctx.getHandler());
      if (allowed && !allowed.includes(decoded.role)) {
        throw new ForbiddenException();
      }
      req.user = decoded; // uid, email, etc. disponible en los handlers
      return true;
    } catch (_) {
      throw new UnauthorizedException('Invalid token');
    }
  }
}
