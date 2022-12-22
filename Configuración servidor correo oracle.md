# Configuración de un servidor de correo postfix para enviar correos desde oracle


## Preparación del servidor
Instalamos postfix y mailutils para poder enviar correos desde el servidor de correo, en este caso, usaremos una cuenta de gmail.

```bash
sudo apt-get install postfix mailutils
```

## Configuración de postfix

1. Modificamos el ficher /etc/postfix/sasl_passwd y añadimos la siguiente línea.
  
  ```bash
  [smtp.gmail.com]:587 correo@gmail.com:contraseña-correo
  ```

2. Le cambiamos los permisos al fichero y le cambiamos el propietario.
  
  ```bash
  sudo chmod 600 /etc/postfix/sasl_passwd
  sudo chown root:root /etc/postfix/sasl_passwd
  ```

3. Cambiamos la política de envío de correo.
  
  ```bash
  sudo nano /etc/postfix/tls_policy
  ```
  
  Y añadimos la siguiente línea.
  
  ```bash
  [smtp.gmail.com]:587 encrypt
  ```

4. Le cambiamos los permisos y el usuario al fichero.
  
  ```bash
  sudo chmod 600 /etc/postfix/tls_policy
  sudo chown root:root /etc/postfix/tls_policy
  ```

5. Añadimos la configuración a postfix.
  
  ```bash
  myhostname = debianprueba
  relayhost = [smtp.gmail.com]:587
  smtp_sasl_auth_enable = yes
  smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
  smtp_tls_policy_maps = hash:/etc/postfix/tls_policy
  smtp_sasl_security_options = noanonymous
  smtp_use_tls = yes
  smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt
  smtp_tls_security_level = encrypt
  ```

6. Mapeamos el fichero de configuración y el de políticas.
  
  ```bash
  sudo postmap /etc/postfix/sasl_passwd
  sudo postmap /etc/postfix/tls_policy
  ```

7. Reiniciamos el servicio de postfix.
  
  ```bash
  sudo systemctl restart postfix
  ```

8. Realizamos el envío de prueba desde la consola de comandos de la siguiente manera:
    
    ```bash
    echo "prueba de envío" | mail -s "Esto es una prueba"
    ```


## Configuración de oracle

1. Accedemos a oracle como sysdba y ejecutamos los siguientes comandos.
  
  ```sql
  @$ORACLE_HOME/rdbms/admin/utlmail.sql
  @$ORACLE_HOME/rdbms/admin/prvtmail.plb 
  ```

  Con esto, creamos el paquete utl_mail y el paquete privado. Estos paquetes son necesarios para poder enviar correos desde oracle.

2. Es necesario crear una ACL para poder enviar correos desde oracle. Para ello, ejecutamos los siguientes comandos.
  
  ```sql
  BEGIN
    DBMS_NETWORK_ACL_ADMIN.CREATE_ACL(
      acl => 'oracle.xml',
      description => 'Enviar correos',
      principal => 'USER',
      is_grant => true,
      privilege => 'connect',
      start_date => SYSTIMESTAMP,
      end_date => NULL
    );
    COMMIT;
  END;
  /
  ```

  Debemos recordad que, aunque creamos los usuarios en mínusculas, oracle los guarda en mayusculas. Por ello, en la variable principal, debemos poner `USER` y no `user`.

3. Asignamos la ACL al usuario que va a enviar los correos.
  
  ```sql
  BEGIN
    DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL (
      acl => 'oracle.xml',
      host => '*',
      lower_port => NULL,
      upper_port => NULL
    );
    COMMIT;
  END;
  /
  ```

4. Le proporcionamos permisos al usuario para poder hacer uso de ejecución del paquete para poder enviar correos.
  
  ```sql
  grant execute on UTL_MAIL to MARIA;
  ```

5. Una vez acabado, comprobamos si podemos enviar un correo desde nuestra consola de oracle.
    
  ```sql
  BEGIN
    UTL_MAIL.SEND (
      sender => 'mariajesus.allozarodriguez@gmail.com',
      recipients => 'mariajesus.allozarodriguez@gmail.com',
      subject => 'Prueba',
      message => 'Esto es un mensaje de prueba. Te hablo desde oracle'
    );
  END;
  /
  ```