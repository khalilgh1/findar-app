# authentications endpoints 

## auth/login
- request format:

{
  "username":
  "password":
}

- succ

{
  "refresh":
  "access":
  "username":
  "email": 
  "account_type":
}

## auth/register
- request format:

{
  "username": 
  "password": 
  "phone_number": 
  "email": 
  "account_type":
}

- succ

{
  "refresh":
  "access":
  "username":
  "email": 
  "account_type":
}

## auth/me
- request format:

--- not implemented yet ---
access token on header only 

{
  "username":
  "email": 
  "account_type":
}
