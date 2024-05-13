import Random = "mo:base/Random";
import Char = "mo:base/Char";
import Error = "mo:base/Error";

actor {

  stable var deck : ?[var Char] = ?[var 
    '🂡','🂢','🂣','🂤','🂥','🂦','🂧','🂨','🂩','🂪','🂫','🂬','🂭','🂮',
    '🂱','🂲','🂳','🂴','🂵','🂶','🂷','🂸','🂹','🂺','🂻','🂼','🂽','🂾',
    '🃁','🃂','🃃','🃄','🃅','🃆','🃇','🃈','🃉','🃊','🃋','🃌','🃍','🃎',
    '🃑','🃒','🃓','🃔','🃕','🃖','🃗','🃘','🃙','🃚','🃛','🃜','🃝','🃞',
    '🃏'
  ];

  func bit(b : Bool) : Nat {
    if (b) 1 else 0;
  };

  /// Given finite source of randomness `f`,
  /// return an optional random number between [0..`max`)
  /// (using rejection sampling).
  /// Return of `null` indicates `f` is exhausted and should be replaced.
  func chooseMax(f : Random.Finite, max : Nat) : ? Nat {
    assert max > 0;
    do ? {
      var n = max - 1 : Nat;
      var k = 0;
      while (n != 0) {
        k *= 2;
        k += bit(f.coin()!);
        n /= 2;
      };
      if (k < max) k else chooseMax(f, max)!;
    };
  };

  public func shuffle() : async () {
    let ?cards = deck else throw Error.reject("shuffle in progess");
    deck := null;
    var f = Random.Finite(await Random.blob());
    var i : Nat = cards.size() - 1;
    while (i > 0) {
      switch (chooseMax(f, i + 1)) {
        case (?j) {
          let temp = cards[i];
          cards[i] := cards[j];
          cards[j] := temp;
          i -= 1;
        };
        case null { // need more entropy
          f := Random.Finite(await Random.blob());
        }
      }
    };
    deck := ?cards;
  };
  
  public query func show() : async Text {
    let ?cards = deck else throw Error.reject("shuffle in progess");
    var t = "";
    for (card in cards.vals()) {
       t #= Char.toText(card);
    };
    return t;
  }

};
