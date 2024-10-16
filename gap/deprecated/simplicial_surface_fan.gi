#! @DoNotReadRestOfFile

##############################################################################
##
#W  simplicial_surface_fan.gi      SimplicialSurfaces         Markus Baumeister
##
##
#Y  Copyright (C) 2016-2017, Markus Baumeister, Lehrstuhl B für Mathematik,
#Y  RWTH Aachen
##
##  This file is free software, see license information at the end.
##
##
##  The functions in this file compute with fans.
##

DeclareRepresentation("IsSimplicialSurfaceFanRep", IsSimplicialSurfaceFan,
     []);

##	accompanying type
SimplicialSurfaceFanType := 
    NewType( SimplicialSurfaceFanFamily, IsSimplicialSurfaceFanRep );



#############################################################################
#############################################################################
##
##						Start of constructors
##
##
##

#!	@Description
#!	Return a fan by defining all necessary attributes. Begin and End have to be
#!	different.
#!	The NC-version doesn't check if Begin and End are different.
#!	@Arguments two positive integers, one cyclic permutation
#!	@Returns a fan
InstallMethod( SimplicialSurfaceFanNC, 
	"for two positive integers and a permutation", [IsPosInt, IsPosInt, IsPerm],
	function( start, fin, perm )
		local fan, corona;

		fan := Objectify( SimplicialSurfaceFanType, rec() );
		SetBeginOfFan( fan, start );
		SetEndOfFan( fan, fin );
		SetPermutationOfFan( fan, perm );

		# Check the corona
		corona := ValueOption( "Corona" );
		if not corona = fail then
			SetCoronaOfFan( fan, corona );
		fi;

		return fan;
	end
);
InstallMethod( SimplicialSurfaceFan, 
	"for two positive integers and a permutation", [IsPosInt, IsPosInt, IsPerm],
	function( start, fin, perm )
		local corona;

		if start = fin then
			Error("SimplicialSurfaceFan: Begin and End have to be different.");
		fi;

		if perm <> () and Order(perm) <> NrMovedPoints(perm) then
			Error("SimplicialSurfaceFan: The permutation has to be a cycle." );
		fi;

		# Check the corona
		corona := ValueOption( "Corona" );
		if not corona = fail then
			if perm <> () and MovedPoints(perm) <> corona then
				Error("SimplicialSurfaceFan: The corona has to be equal to the moved points of the permutation.");
			fi;
		fi;

		return SimplicialSurfaceFanNC( start, fin, perm);
	end
);

#!	@Description
#!	Return the fan of the edge of a simplicial surface. For this to be unique
#!	at most two faces can be incident to the edge (otherwise the permutation
#!	of those is not unique). This is guaranteed to be the case if the simplicial
#!	surface is an actual surface.
#!
#!	@Arguments a simplicial surface, a positive integer
#!	@Returns a fan
InstallMethod( SimplicialSurfaceFanByEdgeInSimplicialSurface,
	"for a simplicial surface and a positive integer",
	[IsSimplicialSurface, IsPosInt],
	function( surface, edge )
		local fan, vertices, faces, perm;

		if not edge in Edges(surface) then
			Error("SimplicialSurfaceFanByEdgeInSimplicialSurface: Given edge has to lie in given surface.");
		fi;

		faces := FacesOfEdges(surface)[edge];
		if Size(faces) = 1 then
			perm := ();
		elif Size(faces) = 2 then
			perm := (faces[1], faces[2] );
		else
			Error("SimplicialSurfaceFanByEdgeInSimplicialSurface: There have to be at most two faces incident to the given edge.");
		fi;

		vertices := VerticesOfEdges(surface)[edge];

		return SimplicialSurfaceFanNC( vertices[1], vertices[2], perm:
															Corona := faces);
	end
);


#!	@Description
#!	Return the fan of the edge of a coloured simplicial surface. For 
#!	this to be unique at most two faces can be incident to the edge equivalence
#!	class (otherwise the permutation of those is not unique).
#!
#!	@Arguments a coloured simplicial surface, a positive integer
#!	@Returns a fan
InstallMethod( SimplicialSurfaceFanByEdgeInColouredSimplicialSurface,
	"for a coloured simplicial surface and a positive integer",
	[IsColouredSimplicialSurface, IsPosInt],
	function( surface, edge )
		local fan, vertices, faces, perm;

		if not edge in EdgeEquivalenceNumbersAsSet(surface) then
			Error("SimplicialSurfaceFanByEdgeInColouredSimplicialSurface: Given edge has to be a class in given surface.");
		fi;

		faces := List( EdgeEquivalenceClassByNumberNC(surface,edge), e ->
						FacesOfEdges(UnderlyingSimplicialSurface(surface))[e] );
		faces := Union( faces );
		if Size(faces) = 1 then
			perm := ();
		elif Size(faces) = 2 then
			perm := (faces[1], faces[2] );
		else
			Error("SimplicialSurfaceFanByEdgeInColouredSimplicialSurface: There have to be at most two faces incident to the given edge equivalence class.");
		fi;

		vertices := VerticesOfEdges(QuotientSimplicialSurface(surface))[edge];

		return SimplicialSurfaceFanNC( vertices[1], vertices[2], perm:
															Corona := faces);
	end
);


##
##
##							End of constructors
##
#############################################################################
#############################################################################




#! @Description
#! Return the corona of the fan.
#! @Arguments a simplicial surface fan
#! @Returns a set of positive integers
InstallMethod( CoronaOfFan,	"for a simplicial surface fan", 
	[IsSimplicialSurfaceFan],
	function( fan )
		return MovedPoints( PermutationOfFan( fan ) );
	end
);


#! @Description
#! Return the inverse of the fan. You get the inverse of a fan by switching
#! Begin and End in addition to inverting the permutation.
#! @Arguments a simplicial surface fan
#! @Returns a positive integers
InstallMethod( InverseOfFan, "for a simplicial surface fan", 
	[IsSimplicialSurfaceFan],
	function( fan )
		local inv;

		inv := SimplicialSurfaceFanNC( EndOfFan(fan), BeginOfFan(fan),
			PermutationOfFan(fan)^(-1) : Corona := CoronaOfFan(fan) );

		# The inverse of the inverse is the original
		SetInverseOfFan( inv, fan);

		return inv;
	end
);


#!	@Description
#!	Return the reduct of a given fan with respect to the given set. The reduct
#!	of a fan is another fan with the same Begin and End but a modified
#!	permutation. The permutation is derived from the cycle-presentation of the
#!	permutation by ignoring all values that doesn't lie in the given set. the
#!	set has to be a subset of the corona.
#!
#!	@Arguments a simplicial surface fan, a set of positive integers
#!	@Returns a simplicial surface fan
InstallMethod( ReducedFanOp, 
	"for a simplicial surface fan and a subset of its corona", 
	[IsSimplicialSurfaceFan, IsSet],
	function( fan, set )
		local i, newPerm, el, reduct;

		if not IsSubset( CoronaOfFan(fan), set ) then
			Error("ReducedFan: Given set has to be a subset of the fan-corona.");
		fi;

		# Check the trivial case
		if CoronaOfFan(fan) = set then
			return fan;
		fi;

		# Modify the permutation
		# The list newPerm is defined by oldPerm[i] = i^perm
		newPerm := ListPerm( PermutationOfFan( fan ) );
		for i in [1..Length(newPerm)] do
			if i in set then
				# If i is in set, we apply the permutation until it lies in set again
				el := i^PermutationOfFan(fan);
				while not el in set do
					el := el^PermutationOfFan(fan);
				od;
				newPerm[i] := el;
			else
				# If i is not in set, it stays fixed
				newPerm[i] := i;
			fi;
		od;

		return SimplicialSurfaceFanNC( BeginOfFan(fan), EndOfFan(fan), 
			PermList( newPerm ) : Corona := set );
	end
);
RedispatchOnCondition( ReducedFan, true, [IsSimplicialSurfaceFan, IsList], 
	[,IsSet], 0 );


#############################################################################
##
##
#!  @Section Functions for fans
#!
#!
#!


#!	@Description
#!	Check if the given fan is the fan of a simplicial surface. This is the case
#!	if there is an edge with Begin and End as vertices and the incident faces
#!	around it are exactly the corona. Then this method returns the correct
#!	edge, otherwise fail.
#!	@Arguments a simplicial surface, a simplicial surface fan
#!	@Returns a positive integer or fail
InstallMethod( EdgeForFanOfSimplicialSurface, 
	"for a simplicial surface and a simplicial surface fan", 
	[IsSimplicialSurface, IsSimplicialSurfaceFan],
	function( surface, fan )
		local edges, verticesOfEdges, e;

		edges := Edges(surface);
		verticesOfEdges := VerticesOfEdges(surface);
		for e in edges do
			if IsEdgeForFanOfSimplicialSurface( surface, fan, e ) then
				return e;
			fi;
		od;

		return fail;
	end
);

#!	@Description
#!	Check if the given fan is the fan of a given edge of a simplicial surface.
#!	This is the case if the edge has Begin and End as vertices and the incident 
#!	faces around it are exactly the corona. Then this method returns true,
#!	otherwise false.
#!	@Arguments a simplicial surface, a simplicial surface fan, a positive 
#!		integer
#!	@Returns true or false
InstallMethod( IsEdgeForFanOfSimplicialSurface, 
	"for a simplicial surface, a simplicial surface fan and an edge number", 
	[IsSimplicialSurface, IsSimplicialSurfaceFan, IsPosInt],
	function( surface, fan, edge )
		local verticesOfEdges, e;

		verticesOfEdges := VerticesOfEdges(surface);
		return verticesOfEdges[edge] = Set( [BeginOfFan(fan), EndOfFan(fan)] )
			and FacesOfEdges(surface)[edge] = CoronaOfFan(fan);
	end
);


#!	@Description
#!	Check if the given fan is the fan of a coloured simplicial surface. 
#!	This is the case if there is an edge equivalence class with Begin and End
#!	as incident vertex equivalence classes and the incident faces (not 
#!	equivalence classes!) around it are exactly the corona.
#!	Then it returns the edge equivalence class, otherwise fail.
#!	@Arguments a coloured simplicial surface, a simplicial surface fan
#!	@Returns a positive integer or fail
InstallMethod( EdgeEquivalenceNumberForFanOfColouredSimplicialSurface, 
	"for a coloured simplicial surface and a simplicial surface fan", 
	[IsColouredSimplicialSurface, IsSimplicialSurfaceFan],
	function( surface, fan )
		local edgeClassNr, edgeByVertexClass, quot, edgeNr, allEdges, faces;

		# Check all edge classes
		quot := QuotientSimplicialSurface( surface );
		edgeClassNr := Edges( quot );
		edgeByVertexClass := VerticesOfEdges( quot );

		for edgeNr in edgeClassNr do
			if IsEdgeEquivalenceNumberForFanOfColouredSimplicialSurface(
					surface, fan, edgeNr ) then
				return edgeNr;
			fi;
		od;
		
		return fail;
	end
);

#!	@Description
#!	Check if the given fan is the fan of a given edge equivalence class of a 
#!	coloured simplicial surface. This is the case if the edge equivalence class
#!	has Begin and End as vertices and the incident faces (not face equivalence
#!	classes!) around it are exactly the corona. Then this method returns true,
#!	otherwise false.
#!	@Arguments a coloured simplicial surface, a simplicial surface fan, a 
#!		positive integer
#!	@Returns true or false
InstallMethod( IsEdgeEquivalenceNumberForFanOfColouredSimplicialSurface, 
	"for a coloured simplicial surface, a simplicial surface fan and an edge equivalence class number", 
	[IsColouredSimplicialSurface, IsSimplicialSurfaceFan, IsPosInt],
	function( surface, fan, edgeClassNr )
		local edgeByVertexClass, quot, allEdges, faces;

		# Check all edge classes
		quot := QuotientSimplicialSurface( surface );
		edgeByVertexClass := VerticesOfEdges( quot );

		if edgeByVertexClass[edgeClassNr] = 
					Set( [BeginOfFan(fan), EndOfFan(fan)] ) then
			# Check corona
			allEdges := EdgeEquivalenceClassesByNumbers(surface)[edgeClassNr];
			faces := List( allEdges, e -> 
				FacesOfEdges( UnderlyingSimplicialSurface( surface ) )[e] );
			if Union( faces ) = CoronaOfFan(fan) then
				return true;
			fi;
		fi;
		
		return false;
	end
);


#TODO is a NC-version useful?
#!	@Description
#!	A fan of a simplicial surface (with colouring) defines an orientation
#!	for an edge (equivalence class). By the right-hand-rule this defines an
#!	orientation for the set of incident faces as well. Since those faces are
#!	oriented as well we can determine which side of the face lies in the 
#!	correct direction.
#!	This method returns +1 if this side is the pre-defined "correctly
#!	oriented" side; and -1 otherwise.
#!	@Arguments a simplicial surface (with colouring), a simplicial surface
#!		fan, a positive integer
#!	@Returns an integer
InstallMethod( FaceOrientationInducedByFan, 
	"for a coloured simplicial surface, a simplicial surface fan and a positive integer", 
	[IsColouredSimplicialSurface, IsSimplicialSurfaceFan, IsPosInt],
	function( surface, fan, face )
		local edgeClassNr, localOrient;

		edgeClassNr := 
			EdgeEquivalenceNumberForFanOfColouredSimplicialSurface( 
																surface, fan);
		if edgeClassNr = fail then
			return fail;
		fi;

		if not face in CoronaOfFan(fan) then
			Error("FaceOrientationInducedByFan: Given face has to lie in the surface.");
		fi;

		localOrient := 
			LocalOrientationWRTVertexEquivalenceClasses(surface);
		if BeginOfFan( fan )^localOrient[face] = EndOfFan( fan ) then
			return 1;
		else
			return -1;
		fi;
	end
);
InstallOtherMethod( FaceOrientationInducedByFan, 
	"for a simplicial surface, a simplicial surface fan and a positive integer", 
	[IsSimplicialSurface, IsSimplicialSurfaceFan, IsPosInt],
	function( surface, fan, face )
		local edgeClassNr, localOrient;

		edgeClassNr := EdgeForFanOfSimplicialSurface( surface, fan);
		if edgeClassNr = fail then
			return fail;
		fi;

		if not face in CoronaOfFan(fan) then
			Error("FaceOrientationInducedByFan: Given face has to lie in the surface.");
		fi;

		localOrient := LocalOrientation(surface);
		if BeginOfFan( fan )^localOrient[face] = EndOfFan( fan ) then
			return 1;
		else
			return -1;
		fi;
	end
);

#!	@Description
#!	A fan of a simplicial surface (with colouring) defines an orientation
#!	for an edge (equivalence class). By the right-hand-rule this defines an
#!	orientation for the set of incident faces as well. Since those faces are
#!	oriented as well we can determine which side of the face lies in the 
#!	correct direction.
#!	This method returns the name of this side of the face.
#!	@Arguments a simplicial surface (with colouring), a simplicial surface
#!		fan, a positive integer
#!	@Returns an integer
InstallMethod( FaceNameInducedByFan, 
	"for a coloured simplicial surface, a simplicial surface fan and a positive integer", 
	[IsColouredSimplicialSurface, IsSimplicialSurfaceFan, IsPosInt],
	function( surface, fan, face )
		local side, faceNames;

		side := FaceOrientationInducedByFan( surface, fan, face);
		faceNames := NamesOfFace( UnderlyingSimplicialSurface( surface ), face );
		return faceNames[ 1/2 * ( 3 - side ) ]; # 1 -> 1, -1 -> 2 (has to stay integer, not float!)
	end
);
InstallOtherMethod( FaceNameInducedByFan, 
	"for a simplicial surface, a simplicial surface fan and a positive integer", 
	[IsSimplicialSurface, IsSimplicialSurfaceFan, IsPosInt],
	function( surface, fan, face )
		local side, faceNames;

		side := FaceOrientationInducedByFan( surface, fan, face);
		faceNames := NamesOfFace( surface, face );
		return faceNames[ 1/2 * ( 3 - side ) ]; # 1 -> 1, -1 -> 2 (has to stay integer, not float!)
	end
);

#############################################################################
##
#!  @Description
#!  Check if two simplicial surface fans are equal.
#!  @Returns true or false
#!  @Arguments <s1>, <s2>, two simplicial surface fan objects
#!
##
InstallMethod( \=, "for two simplicial surfaces", IsIdenticalObj, 
  [ IsSimplicialSurfaceFan, IsSimplicialSurfaceFan ],
	function( s1, s2 )
		# check all basic attributes

		if BeginOfFan(s1) <> BeginOfFan(s2) then
			return false;
		fi;
		if EndOfFan(s1) <> EndOfFan(s2) then
			return false;
		fi;
		if PermutationOfFan(s1) <> PermutationOfFan(s2) then
			return false;
		fi;

		if CoronaOfFan(s1) <> CoronaOfFan(s2) then
			return false;
		fi;

        return true;
	end
);


#############################################################################
##
##  A Print method for simplicial surface fans
##
InstallMethod( PrintObj, "for simplicial surface fans", 
	[ IsSimplicialSurfaceFan ],
	function(fan)

        Print("SimplicialSurfaceFanNC( ");
        Print( BeginOfFan(fan), ", ");
        Print( EndOfFan(fan), ", ");
        Print( PermutationOfFan(fan), " : Corona := ");
        Print( CoronaOfFan(fan), " );\n");
	end
);

#
###  This program is free software: you can redistribute it and/or modify
###  it under the terms of the GNU General Public License as published by
###  the Free Software Foundation, either version 3 of the License, or
###  (at your option) any later version.
###
###  This program is distributed in the hope that it will be useful,
###  but WITHOUT ANY WARRANTY; without even the implied warranty of
###  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
###  GNU General Public License for more details.
###
###  You should have received a copy of the GNU General Public License
###  along with this program.  If not, see <http://www.gnu.org/licenses/>.
###
