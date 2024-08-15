// Copyright (c) Microsoft.  All Rights Reserved.  Licensed under the MIT license.  See License.txt in the project root for license information.

using System.Threading;
using System.Threading.Tasks;
using Microsoft.CodeAnalysis.Tools.Commands;

namespace Microsoft.CodeAnalysis.Tools
{
    internal class Program
    {
        private static async Task<int> Main(string[] args)
        {
            var rootCommand = RootFormatCommand.GetCommand();
            return await rootCommand.Parse(args).InvokeAsync(CancellationToken.None);
        }
    }
}
