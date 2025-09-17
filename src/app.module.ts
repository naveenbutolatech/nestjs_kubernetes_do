import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { UsersModule } from './users/users.module';
import { ProductsModule } from './products/products.module';
import { CategoriesModule } from './categories/categories.module';
import { User } from './entities/user.entity';
import { Product } from './entities/product.entity';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        host: configService.get('DATABASE_HOST', 'localhost'),
        port: configService.get('DATABASE_PORT', 5432),
        username: configService.get('DATABASE_USER', 'postgres'),
        password: configService.get('DATABASE_PASSWORD', 'postgres'),
        database: configService.get('DATABASE_NAME', 'nestdb'),
        entities: [__dirname + '/**/*.entity{.ts,.js}'],
        synchronize: true, // Enable for Docker container testing
        logging: true, // Enable logging to see what's happening
        autoLoadEntities: true, // Automatically load entities
        ssl: {
          rejectUnauthorized: false, // Required for DigitalOcean PostgreSQL
        },
        extra: {
          ssl: {
            sslmode: 'require', // Match DigitalOcean requirement
          },
        },
        // Retry connection configuration
        retryAttempts: 3,
        retryDelay: 3000,
        // VPC database configuration - using private hostname
      }),
      inject: [ConfigService],
    }),
    UsersModule,
    ProductsModule,
    CategoriesModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
