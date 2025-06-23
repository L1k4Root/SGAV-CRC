export interface UserDTO {
  id?: string;
  uid: string; // mismo uid de FirebaseAuth
  email: string;
  role: 'resident' | 'guard' | 'admin';
}
export abstract class IUsersRepository {
  abstract findByUid(uid: string): Promise<UserDTO | null>;
  abstract create(data: UserDTO): Promise<void>;
}
