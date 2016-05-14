{******************************************************************************}
{                                                                              }
{  Delphi OPENSSL Library                                                      }
{  Copyright (c) 2016 Luca Minuti                                              }
{  https://bitbucket.org/lminuti/delphi-openssl                                }
{                                                                              }
{******************************************************************************}
{                                                                              }
{  Licensed under the Apache License, Version 2.0 (the "License");             }
{  you may not use this file except in compliance with the License.            }
{  You may obtain a copy of the License at                                     }
{                                                                              }
{      http://www.apache.org/licenses/LICENSE-2.0                              }
{                                                                              }
{  Unless required by applicable law or agreed to in writing, software         }
{  distributed under the License is distributed on an "AS IS" BASIS,           }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    }
{  See the License for the specific language governing permissions and         }
{  limitations under the License.                                              }
{                                                                              }
{******************************************************************************}
unit OpenSSL.Core;

interface

uses
  System.Classes, System.SysUtils;

type
  TRASPadding = (
    rpPKCS,           // use PKCS#1 v1.5 padding (default),
    rpOAEP,           // use PKCS#1 OAEP
    rpSSL,            // use SSL v2 padding
    rpRAW             // use no padding
    );

  EOpenSSLError = Exception;

  EOpenSSLLibError = class(EOpenSSLError)
  private
    FErrorCode: Integer;
  public
    constructor Create(Code :Integer; const Msg: string);
    property ErrorCode :Integer read FErrorCode;
  end;

  TOpenSLLBase = class
  public
    constructor Create; virtual;
  end;

function GetOpenSSLErrorMessage: string;

function OpenSSLEncodeFileName(const FileName :string) :PAnsiChar;

procedure RaiseOpenSSLError(const AMessage :string = '');

implementation

uses
  IdSSLOpenSSLHeaders, OpenSSL.libeay32;

function OpenSSLEncodeFileName(const FileName :string) :PAnsiChar;
var
  Utf8FileName: RawByteString;
begin
  Utf8FileName := UTF8Encode(FileName);
  Result := PAnsiChar(Utf8FileName);
end;

function GetOpenSSLErrorMessage: string;
var
  ErrMsg: PAnsiChar;
begin
  ErrMsg := ERR_error_string(ERR_get_error, nil);
  Result := string(AnsiString(ErrMsg));
end;

procedure RaiseOpenSSLError(const AMessage :string);
var
  ErrCode: Integer;
  ErrMsg, FullMsg: string;
begin
  ErrCode := ERR_get_error;
  ErrMsg := string(AnsiString(ERR_error_string(ErrCode, nil)));
  if AMessage = '' then
    FullMsg := ErrMsg
  else
    FullMsg := AMessage + ': ' + ErrMsg;
  raise EOpenSSLLibError.Create(ErrCode, FullMsg);
end;

procedure CheckOpenSSLLibrary;
begin
  if not LoadOpenSSLLibraryEx then
    raise EOpenSSLError.Create('Cannot open "OpenSSL" library');
end;

{ TOpenSLLBase }

constructor TOpenSLLBase.Create;
begin
  inherited;
  CheckOpenSSLLibrary;
end;

{ EOpenSSLLibError }

constructor EOpenSSLLibError.Create(Code: Integer; const Msg: string);
begin
  FErrorCode := Code;
  inherited Create(Msg);
end;

end.