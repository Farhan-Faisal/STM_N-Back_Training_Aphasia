% copyright 2009-2012 Blair Armstrong, Christine Watson, David Plaut
%
%    This file is part of SOS
%
%    SOS is free software: can redistribute it and/or modify
%    it for academic and non-commercial purposes
%    under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.  For commercial or for-profit
%    uses, please contact the authors (sos@cnbc.cmu.edu).
%
%    SOS is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.

%    You should have received a copy of the GNU General Public License
%    along with SOS (see COPYING.txt).
%    If not, see <http://www.gnu.org/licenses/>.


% creates icon resource file
%used in windows, matlab2010a
system(['"' matlabroot '\sys\lcc\bin\lrc" /i "' pwd '\sos.rc"']);