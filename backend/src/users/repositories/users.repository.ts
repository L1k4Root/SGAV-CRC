import { Injectable } from '@nestjs/common';
import { IUsersRepository, UserDTO } from './users.repository.interface';
import { db } from 'src/firebase';

@Injectable()
export class UsersFirestoreRepository implements IUsersRepository {
  private col = db.collection('users');
  async findByUid(uid: string): Promise<UserDTO | null> {
    const doc = await this.col.doc(uid).get();
    if (!doc.exists) return null;
    return { uid: doc.id, ...doc.data() } as UserDTO;
  }
  async create(data: UserDTO) {
    await this.col.doc(data.uid).set(data);
  }
}
