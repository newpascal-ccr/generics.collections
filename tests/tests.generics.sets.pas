{
    This file is part of the Free Pascal run time library.
    Copyright (c) 2018 by Maciej Izak (hnb),
    member of the Free Pascal development team

    It contains tests for the Free Pascal generics library

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

    Acknowledgment

    Thanks to Sphere 10 Software (http://sphere10.com) for sponsoring
    many new types, tests and major refactoring of entire library

 **********************************************************************}
unit tests.generics.sets;

{$mode delphi}

interface

uses
  fpcunit, testregistry, testutils,
  Classes, SysUtils, Generics.Collections;

type
  THashSet_Integer = THashSet<Integer>;
  TSortedSet_Integer = TSortedSet<Integer>;
  TSortedHashSet_Integer = TSortedHashSet<Integer>;

  { TTestSets }

  TTestSets = class(TTestCase)
  public
    constructor Create; override;
  published
    procedure Test_HashSet_General;
    procedure Test_SortedSet_General;
    procedure Test_SortedHashSet_General;
    procedure Test_HashSet;
    procedure Test_SortedSet;
    procedure Test_SortedHashSet;
  end;

  { TGenericTestSets }

  TGenericTestSets<T> = record
    class procedure ValidateSet(ASet: T; const ANumbers: array of Integer); static;
    class procedure Test_Set_General; static;
    class procedure Test_Set_Sorted; static;
    class procedure Test_Set_NonSorted; static;
  end;

var
  GTest: TTestSets;

procedure CheckSet_10(ASet: TCustomSet<Integer>; ASortedList: TSortedList<Integer>);

implementation

{ TGenericTestSets }

class procedure TGenericTestSets<T>.ValidateSet(ASet: T;
  const ANumbers: array of Integer);
var
  i: Integer;
begin with GTest do begin
  for i in ANumbers do
    AssertTrue('Can''t find number ' + i.ToString, ASet.Contains(i));
  AssertEquals(ASet.Count, Length(ANumbers));
end end;

class procedure TGenericTestSets<T>.Test_Set_General;
var
  NumbersA: T;
  NumbersB: T;
  NumbersC: T;
  i: Integer;
begin with GTest do begin
  NumbersA := T.Create;
  NumbersB := T.Create;

  for i := 0 to 4 do
  begin
    AssertTrue(NumbersA.Add(i * 2));
    AssertTrue(NumbersB.Add((i * 2) + 1));
  end;

  ValidateSet(NumbersA, [0, 2, 4, 6, 8]);
  ValidateSet(NumbersB, [1, 3, 5, 7, 9]);

  { UnionWith }
  NumbersC := T.Create(NumbersA);
  NumbersC.UnionWith(NumbersB);
  ValidateSet(NumbersC, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
  AssertFalse(NumbersC.Add(5));
  AssertFalse(NumbersC.AddRange([6, 7]));
  AssertEquals(NumbersC.Count, 10);

  { ExceptWith }
  NumbersC.ExceptWith(NumbersB);
  AssertEquals(NumbersC.Count, 5);
  ValidateSet(NumbersC, [0, 2, 4, 6, 8]);
  AssertTrue(NumbersC.AddRange(NumbersB));
  ValidateSet(NumbersC, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);

  { SymmetricExceptWith }
  NumbersA.Clear;
  AssertEquals(NumbersA.Count, 0);
  NumbersB.Clear;
  AssertEquals(NumbersB.Count, 0);
  NumbersC.Clear;
  AssertEquals(NumbersC.Count, 0);
  AssertTrue(NumbersA.AddRange([0, 1, 2, 3, 4, 5]));
  ValidateSet(NumbersA, [0, 1, 2, 3, 4, 5]);
  AssertTrue(NumbersB.AddRange([3, 4, 5, 6, 7, 8, 9]));
  ValidateSet(NumbersB, [3, 4, 5, 6, 7, 8, 9]);
  NumbersC.Free;
  NumbersC := T.Create(NumbersA);
  ValidateSet(NumbersC, [0, 1, 2, 3, 4, 5]);
  NumbersC.SymmetricExceptWith(NumbersB);
  ValidateSet(NumbersC, [0, 1, 2, 8, 7, 6, 9]);

  { IntersectWith }
  NumbersA.Clear;
  AssertEquals(NumbersA.Count, 0);
  NumbersB.Clear;
  AssertEquals(NumbersB.Count, 0);
  NumbersC.Clear;
  AssertEquals(NumbersC.Count, 0);
  AssertTrue(NumbersA.AddRange([0, 1, 2, 3, 4, 5]));
  AssertTrue(NumbersB.AddRange([3, 4, 5, 6, 7, 8, 9]));
  AssertTrue(NumbersC.AddRange(NumbersA));
  NumbersC.IntersectWith(NumbersB);
  ValidateSet(NumbersC, [3, 4, 5]);

  NumbersC.Free;
  NumbersB.Free;
  NumbersA.Free;
end end;

class procedure TGenericTestSets<T>.Test_Set_Sorted;
const
  SORTED_NUMBERS: array[0..9] of Integer = (0, 1, 2, 3, 4, 5, 6, 7, 8, 9);
var
  Numbers: T;
  i, j: Integer;
  pi: PInteger;
begin with GTest do begin
  Numbers := T.Create;
  AssertTrue(Numbers.AddRange([8, 4, 6, 2, 0, 9, 5, 7, 3, 1]));
  ValidateSet(Numbers, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);

  j := 0;
  for i in TCustomSet<Integer>(Numbers) do
  begin
    AssertEquals(i, SORTED_NUMBERS[j]);
    Inc(j);
  end;

  j := 0;
  for pi in TCustomSet<Integer>(Numbers).Ptr^ do
  begin
    AssertEquals(pi^, SORTED_NUMBERS[j]);
    Inc(j);
  end;

  Numbers.Free;
end end;

procedure CheckSet_10(ASet: TCustomSet<Integer>; ASortedList: TSortedList<Integer>);
var
  i: Integer;
begin with GTest do begin
  AssertEquals(ASortedList.Count, 10);
  for i := 0 to 9 do
  begin
    AssertEquals(i, ASortedList[i]);
    AssertTrue(ASet.Contains(i));
  end;
end end;

class procedure TGenericTestSets<T>.Test_Set_NonSorted;
var
  Numbers: T;
  LSortedList: TSortedList<Integer>;
  i: Integer;
  pi: PInteger;
begin with GTest do begin
  Numbers := T.Create;
  LSortedList := TSortedList<Integer>.Create;
  AssertTrue(Numbers.AddRange([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]));
  ValidateSet(Numbers, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);

  for i in TCustomSet<Integer>(Numbers) do
    LSortedList.Add(i);
  CheckSet_10(Numbers, LSortedList);

  LSortedList.Clear;

  for pi in TCustomSet<Integer>(Numbers).Ptr^ do
    LSortedList.Add(pi^);
  CheckSet_10(Numbers, LSortedList);


  LSortedList.Free;
  Numbers.Free;
end end;

{ TTestSets }

constructor TTestSets.Create;
begin
  inherited Create;
  GTest := Self;
end;

procedure TTestSets.Test_HashSet_General;
begin
  TGenericTestSets<THashSet_Integer>.Test_Set_General;
end;

procedure TTestSets.Test_SortedSet_General;
begin
  TGenericTestSets<TSortedSet_Integer>.Test_Set_General;
end;

procedure TTestSets.Test_SortedHashSet_General;
begin
  TGenericTestSets<TSortedHashSet_Integer>.Test_Set_General;
end;

procedure TTestSets.Test_HashSet;
begin
  TGenericTestSets<THashSet_Integer>.Test_Set_NonSorted;
end;

procedure TTestSets.Test_SortedSet;
begin
  TGenericTestSets<TSortedSet_Integer>.Test_Set_Sorted;
end;

procedure TTestSets.Test_SortedHashSet;
begin
  TGenericTestSets<TSortedHashSet_Integer>.Test_Set_Sorted;
end;

begin
  RegisterTest(TTestSets);
end.

