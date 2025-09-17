import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';

@Injectable()
export class AppService {
  constructor(
    @InjectDataSource()
    private dataSource: DataSource,
  ) {}

  getHello(): string {
    return 'Hello World!';
  }

  async getHealth(): Promise<{ status: string; timestamp: string; database: string }> {
    let databaseStatus = 'disconnected';
    
    try {
      await this.dataSource.query('SELECT 1');
      databaseStatus = 'connected';
    } catch (error) {
      databaseStatus = 'error';
    }

    return {
      status: databaseStatus === 'connected' ? 'ok' : 'error',
      timestamp: new Date().toISOString(),
      database: databaseStatus,
    };
  }
}
