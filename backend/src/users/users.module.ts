import { Module } from '@nestjs/common';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';
import { REPOSITORY } from 'src/common/repositories/repository.token';
import { UsersFirestoreRepository } from './repositories/users.repository';

@Module({
  controllers: [UsersController],
  providers: [
    UsersService,
    {
      provide: REPOSITORY.USERS,
      useClass: UsersFirestoreRepository,
    },
  ],
})
export class UsersModule {}
