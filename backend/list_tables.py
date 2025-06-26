#!/usr/bin/env python3
import boto3

def main():
    print("🔍 Buscando tablas de DynamoDB...")
    
    try:
        dynamodb = boto3.client('dynamodb', region_name='us-east-1')
        response = dynamodb.list_tables()
        
        print("📋 Tablas encontradas:")
        for table_name in response['TableNames']:
            print(f"   - {table_name}")
            
        # Buscar tablas que contengan 'networking' o 'passport'
        print("\n🎯 Tablas que podrían ser la correcta:")
        for table_name in response['TableNames']:
            if 'networking' in table_name.lower() or 'passport' in table_name.lower():
                print(f"   ✅ {table_name}")
                
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    main() 