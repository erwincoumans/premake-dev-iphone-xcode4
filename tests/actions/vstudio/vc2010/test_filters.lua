--
-- tests/actions/vstudio/vc2010/test_filters.lua
-- Validate generation of file filter blocks in Visual Studio 2010 C/C++ projects.
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
--

	T.vs2010_filters = { }
	local suite = T.vs2010_filters
	local vc2010 = premake.vstudio.vc2010	


--
-- Setup/teardown
--

	local sln, prj
	
	function suite.setup()
		_ACTION = "vs2010"
		sln = test.createsolution()
	end

	local function prepare(group)
		prj = premake.solution.getproject_ng(sln, 1)
		vc2010.filters_filegroup(prj, group)
	end


--
-- Check contents of the different file groups.
--

	function suite.itemGroup_onClInclude()
		files { "hello.c", "hello.h", "hello.rc", "hello.txt" }
		prepare("ClInclude")
		test.capture [[
	<ItemGroup>
		<ClInclude Include="hello.h" />
	</ItemGroup>
		]]
	end

	function suite.itemGroup_onResourceSection()
		files { "hello.c", "hello.h", "hello.rc", "hello.txt" }
		prepare("ResourceCompile")
		test.capture [[
	<ItemGroup>
		<ResourceCompile Include="hello.rc" />
	</ItemGroup>
		]]
	end

	function suite.itemGroup_onNoneSection()
		files { "hello.c", "hello.h", "hello.rc", "hello.txt" }
		prepare("None")
		test.capture [[
	<ItemGroup>
		<None Include="hello.txt" />
	</ItemGroup>
		]]
	end


--
-- Files with a build rule go into a custom build section.
--

	function suite.itemGroup_onBuildRule()
		files { "hello.c", "hello.h", "hello.rc", "hello.cg" }
		configuration "**.cg"
			buildrule {
				commands = { "cgc $(InputFile)" },
				outputs = { "$(InputName).obj" }
			}
		prepare("CustomBuild")
		test.capture [[
	<ItemGroup>
		<CustomBuild Include="hello.cg" />
	</ItemGroup>
		]]
	end

	function suite.itemGroup_onSingleConfigBuildRule()
		files { "hello.c", "hello.h", "hello.rc", "hello.cg" }
		configuration { "Release", "**.cg" }
			buildrule {
				commands = { "cgc $(InputFile)" },
				outputs = { "$(InputName).obj" }
			}
		prepare("CustomBuild")
		test.capture [[
	<ItemGroup>
		<CustomBuild Include="hello.cg" />
	</ItemGroup>
		]]
	end


--
-- Files located at the root (in the same folder as the project) do not
-- need a filter identifier.
--

	function suite.noFilter_onRootFiles()
		files { "hello.c", "goodbye.c" }
		prepare("ClCompile")
		test.capture [[
	<ItemGroup>
		<ClCompile Include="goodbye.c" />
		<ClCompile Include="hello.c" />
	</ItemGroup>
		]]
	end

--
-- Check the filter with a real path.
--

	function suite.filter_onRealPath()
		files { "src/hello.c", "hello.h" }
		prepare("ClCompile")
		test.capture [[
	<ItemGroup>
		<ClCompile Include="src\hello.c">
			<Filter>src</Filter>
		</ClCompile>
	</ItemGroup>
		]]
	end

--
-- Check the filter with a virtual path.
--

	function suite.filter_onVpath()
		files { "src/hello.c", "hello.h" }
		vpaths { ["Source Files"] = "**.c" }		
		prepare("ClCompile")
		test.capture [[
	<ItemGroup>
		<ClCompile Include="src\hello.c">
			<Filter>Source Files</Filter>
		</ClCompile>
	</ItemGroup>
		]]
	end
