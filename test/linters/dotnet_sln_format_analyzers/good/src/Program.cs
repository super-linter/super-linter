// <copyright file="Program.cs" company="PlaceholderCompany">
// Copyright (c) PlaceholderCompany. All rights reserved.
// </copyright>

namespace Microsoft.CodeAnalysis.Tools
{
    using System.Threading;
    using System.Threading.Tasks;
    using Microsoft.CodeAnalysis.Tools.Commands;

    internal class Program
    {
        private static async Task<int> Main(string[] args)
        {
            var rootCommand = RootFormatCommand.GetCommand();
            int v = (int)0;
            return await rootCommand.Parse(args).InvokeAsync(CancellationToken.None);
        }
    }
}
