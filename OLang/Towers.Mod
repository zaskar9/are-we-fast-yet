(* This code is derived from the SOM benchmarks, see AUTHORS.md file.
 *
 * Copyright (c) 2025 Rochus Keller <me@rochus-keller.ch> (for Oberon 90 migration)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the 'Software'), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *)
 
MODULE Towers;
IMPORT Benchmark, SOM, Out;

CONST
  PilesCount = 3;

TYPE
  INT32 = SOM.INT32;
  TowersDisk* = POINTER TO TowersDiskDesc;
  TowersDiskDesc* = RECORD (SOM.ObjectDesc)
    size: INT32;
    next: TowersDisk
  END;

  Towers* = POINTER TO TowersDesc;
  TowersDesc* = RECORD (Benchmark.BenchmarkDesc)
    piles: ARRAY PilesCount OF TowersDisk;
    movesDone: INT32
  END;
    
  Result = POINTER TO RECORD (SOM.ObjectDesc) res: INT32 END;

PROCEDURE DisposeTowersDisk(disk: TowersDisk);
BEGIN
  IF disk.next # NIL THEN DisposeTowersDisk(disk.next) END;
  DISPOSE(disk)
END DisposeTowersDisk;  

PROCEDURE CreateTowersDisk(size: INT32): TowersDisk;
  VAR disk: TowersDisk;
BEGIN
  NEW(disk);
  disk.next := NIL;
  disk.size := size;
  RETURN disk
END CreateTowersDisk;

PROCEDURE PushDisk(b: Towers; disk: TowersDisk; pile: INT32);
  VAR top: TowersDisk;
BEGIN
  top := b.piles[pile];
  IF (top # NIL) & (disk.size >= top.size) THEN 
    HALT(101)
  END;
  disk.next := top;
  b.piles[pile] := disk
END PushDisk;

PROCEDURE PopDiskFrom(b: Towers; pile: INT32): TowersDisk;
  VAR top: TowersDisk;
BEGIN
  top := b.piles[pile];
  IF top = NIL THEN HALT(102) END;
  b.piles[pile] := top.next;
  top.next := NIL;
  RETURN top
END PopDiskFrom;

PROCEDURE MoveTopDisk(b: Towers; from, to: INT32);
BEGIN
  PushDisk(b, PopDiskFrom(b, from), to);
  INC(b.movesDone)
END MoveTopDisk;

PROCEDURE BuildTowerAt(b: Towers; pile, disks: INT32);
  VAR i: INT32;
BEGIN
  i := disks;
  WHILE i >= 0 DO
    PushDisk(b, CreateTowersDisk(i), pile);
    DEC(i)
  END
END BuildTowerAt;

PROCEDURE MoveDisks(b: Towers; disks, from, to: INT32);
  VAR other: INT32;
BEGIN
  IF disks = 1 THEN
    MoveTopDisk(b, from, to)
  ELSE
    other := (3 - from) - to;
    MoveDisks(b, disks - 1, from, other);
    MoveTopDisk(b, from, to);
    MoveDisks(b, disks - 1, other, to)
  END
END MoveDisks;

PROCEDURE DoBenchmark*(b: Benchmark.Benchmark): SOM.Object;
  VAR t: Towers; res: SOM.Object; intRes: Result;
BEGIN
  t := b(Towers);
  (* t.piles := SOM.CreateVector(3); *)
  t.piles[0] := NIL;
  t.piles[1] := NIL;
  t.piles[2] := NIL;
  BuildTowerAt(t, 0, 13);
  t.movesDone := 0;
  MoveDisks(t, 13, 0, 1);
  NEW(intRes); intRes.res := t.movesDone;
  res := intRes;
  RETURN res
END DoBenchmark;

PROCEDURE VerifyResult*(b: Benchmark.Benchmark; result: SOM.Object): BOOLEAN;
  VAR val: INT32;
BEGIN
  val := result(Result).res;
  RETURN val = 8191
END VerifyResult;

PROCEDURE Create*(): Benchmark.Benchmark;
  VAR t: Towers;
BEGIN
  NEW(t);
  t.DoBenchmark := DoBenchmark;
  t.VerifyResult := VerifyResult;
  t.InnerBenchmarkLoop := Benchmark.InnerBenchmarkLoop;
  RETURN t
END Create;

END Towers.

