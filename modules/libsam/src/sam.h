#pragma once

__declspec(dllexport) void SetInput(unsigned char* _input);
__declspec(dllexport) void SetSpeed(unsigned char _speed);
__declspec(dllexport) void SetPitch(unsigned char _pitch);
__declspec(dllexport) void SetMouth(unsigned char _mouth);
__declspec(dllexport) void SetThroat(unsigned char _throat);
__declspec(dllexport) void EnableSingmode();
__declspec(dllexport) int testFFI();
__declspec(dllexport) void RunCmdStyle(int argc, char** argv);
__declspec(dllexport) int SAMMain();
__declspec(dllexport) char* GetBuffer();
__declspec(dllexport) int GetBufferLength();
