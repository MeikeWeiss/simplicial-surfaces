##############################################################################
##
#W  wild_simplicial_surface.gd          Simplicial             Alice Niemeyer
##
##
#Y  Copyright (C) 2016-2017, Alice Niemeyer, Lehrstuhl B für Mathematik,
#Y  RWTH Aachen
##
##  This file is free software, see license information at the end.
##
##  This file contains the declaration part for the wild simplicial surfaces
##	of the Simplicial package.
##


#############################################################################
##
#!  @Chapter Wild Coloured Simplicial Surfaces
##
#!  A simplicial surface is called **wild-coloured** if there exists a 
#!  map 
#!
#!


##
##	Declare the representation of generic simplicial surfaces.
##
##	Note: We depart from the usual convention to put this declaration into
##		the .gi-file (compare section 79.19 of the GAP-manual) as it is
##		instrumental to know this representation to work with this package.
##
DeclareRepresentation("IsWildSimplicialSurfaceRep", IsSimplicialSurface,
     ["faces","edges","vertices", "generators"]);

# From now on, we can do "Objectify( WildSimplicialSurfaceType, re )" 
# for any list re
WildSimplicialSurfaceType := 
    NewType( SimplicialSurfaceFamily, IsWildSimplicialSurfaceRep );

## Constructor
DeclareGlobalFunction( "WildSimplicialSurface" );





#############################################################################
##
##
#!  @Section Basic functions for Wild Coloured Simplicial Surfaces
#!
#!
#!

#############################################################################
##
##
#!  @Description
#!  This function returns the list of faces of a  simplicial surface.
#!  Each face of the surface is represented by a number $f$.
#!  @Returns a list
#!  @Arguments simpsurf
#!
DeclareGlobalFunction( "FacesOfWildSimplicialSurface" );
#############################################################################
##
##
#!  @Description
#!  This function returns the list of edges of a  simplicial surface.
#!  Each edge of the surface is represented by a pair of numbers $[f_1,f_2]$,
#!  where $f_1$ and $f_2$ are faces that are incident to the edge $[f_1,f_2]$.
#!  @Returns a list
#!  @Arguments simpsurf
#!
DeclareGlobalFunction( "EdgesOfWildSimplicialSurface" );
#############################################################################
##
##
#!  @Description
#!  This function returns the list of vertices of a  simplicial surface.
#!  Each vertex of the simplicial surface is represented by a vertex 
#!  defining path.
#!  @Returns a list
#!  @Arguments simpsurf
#!
DeclareGlobalFunction( "VerticesOfWildSimplicialSurface" );



#############################################################################
##
##
#!  @Section Functions for Wild Coloured Simplicial Surfaces
#!
#!
#!
DeclareGlobalFunction( "MrTypeOfWildSimplicialSurface" );
#############################################################################
##
##  AllWildSimplicialSurfaces( gens[, mrtype] ) . . . . all simplicial surfaces
##  AllWildSimplicialSurfaces( grp[, mrtype] )
##  AllWildSimplicialSurfaces( sig1, sig2, sig3[, mrtype] )
##
##
#!  @Description
#!  This function computes all wild-coloured simplicial surfaces generated
#!  by a triple of involutions as specified in the input. If the optional
#!  argument <mrtype> is present, only those wit a predefined mrtype are
#!  constructed.
#!  The involution triple can be given to the function in various ways.
#!  Either they are input as a list <gens> of three involutions, or as
#!  a group <grp> whose generators are the tree involutions, or they can
#!  be input into the function as three arguments, one for each involution.
#! 
#!  In case the optional argument <mrtype>  is present, it can be used to
#!  restrict to wild-colourings for which some or all edges have a predefined
#!  colour. This is equivalent to marking the cycles of the three involutions
#!  as follows. If the edge $(j, j^\sigma_i)$ of the involution $\sigma_i$ is
#!  to be a reflection (mirror) let $k=1$, if it is to be a rotation, let 
#!  $k=2$ and if it can be either let $k=0.$ Then set $mrtype[i][j] = k$.
#!  @Returns a list of all wild-coloured simplicial surfaces with generating
#!  set given by three involutions.
#!  The function AllWildSimplicialSurfaces when called with the optional argument
#!  <mrtype> now returns all wild-coloured simplicial surfaces whose edges
#!  are coloured according to the restrictions imposed by <mrtype>.
#!  @Arguments gens,  a list of three involutions
#!
DeclareGlobalFunction( "AllWildSimplicialSurfaces" );
DeclareGlobalFunction( "VertexRelationOfEdge" );
DeclareGlobalFunction( "VertexGroupOfWildSimplicialSurface" );
DeclareGlobalFunction( "IsConnectedWildSimplicialSurface" );
DeclareGlobalFunction( "IsOrientableWildSimplicialSurface" );
#DeclareGlobalFunction( "GeneratorsFromEdgesOfPlainWildSimplicialSurface"); #TODO does not exist
DeclareGlobalFunction( "GeneratorsFromEdgesOfWildSimplicialSurface");
DeclareGlobalFunction( "WildSimplicialSurfacesFromFacePath");
#DeclareGlobalFunction( "WildSimplicialSurfacesFromPlainSurface"); #TODO does not exist
DeclareGlobalFunction( "SnippOffEarsOfWildSimplicialSurface");
DeclareGlobalFunction( "SixFoldCover");
DeclareGlobalFunction( "AllStructuresWildSimplicialSurface");
DeclareGlobalFunction( "StructuresWildSimplicialSurface");
#DeclareGlobalFunction( "ImageWildSimplicialSurface");
DeclareGlobalFunction( "WildSimplicialSurfacesFromGenericSurface" );
#DeclareGlobalFunction( "CommonCover"); # TODO does not exist

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
