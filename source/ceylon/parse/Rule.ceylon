import ceylon.language.meta.model {
    Generic,
    Type,
    Function
}

"A rule. Specifies produced and consumed symbols and a method to execute them"
shared class Rule {
    shared Object(Object?*) consume;
    shared ProductionClause[] consumes;
    shared Atom produces;
    shared Integer precedence;
    shared Associativity associativity;
    shared actual Integer hash;
    shared AnyGrammar g;

    shared new (Function<Object,Nothing> consume,
            ProductionClause[] consumes,
            Atom produces,
            Integer precedence,
            Associativity associativity,
            AnyGrammar g) {
        this.consume = (Object?* x) => consume.apply(*x);
        this.consumes = consumes;
        this.produces = produces;
        this.precedence = precedence;
        this.associativity = associativity;
        this.hash = consumes.hash ^ 2 + produces.hash;
        this.g = g;
    }

    shared new TupleRule(Type<Tuple<Anything,Anything,Anything[]>> tuple,
            AnyGrammar g) {
        this.produces = Atom(tuple);
        this.consume = (Anything * a) => a;
        this.precedence = 0;
        this.associativity = nonassoc;

        assert(is Type<Anything[]>&Generic tuple);
        this.consumes = clausesFromTupleType(tuple, g);
        this.hash = consumes.hash ^ 2 + produces.hash;
        this.g = g;
    }

    shared Boolean precedenceConflict(Rule other) {
        if (precedence >= other.precedence) { return false; }
        if (produces != other.produces) { return false; }
        if (bracketed || other.bracketed) { return false; }
        return true;
    }

    shared Boolean bracketed {
        if (exists c = consumes.first,
            c.contains(produces)) { return false; }
        if (exists c = consumes.last,
            c.contains(produces)) { return false; }
        return true;
    }

    shared Integer? forbidPosition(Rule other) {
        if (other.precedence != precedence) { return null; }
        if (other.associativity != associativity) { return null; }
        if (other.produces != produces) { return null; }

        if (associativity == rassoc) { return 0; }
        if (associativity == lassoc) { return consumes.size - 1; }
        return null;
    }

    shared void predictAll() { for (c in consumes) { c.predict(); } }
}